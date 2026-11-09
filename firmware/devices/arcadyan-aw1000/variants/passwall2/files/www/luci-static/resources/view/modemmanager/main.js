'use strict';
'require view';
'require rpc';
'require ui';
'require form';
'require uci';

var callStatus       = rpc.declare({ object: 'luci.modemmanager', method: 'status' });
var callSetBands     = rpc.declare({ object: 'luci.modemmanager', method: 'set_bands', params: [ 'bands', 'tech' ] });
var callResetBands   = rpc.declare({ object: 'luci.modemmanager', method: 'reset_bands' });
var callRestartModem = rpc.declare({ object: 'luci.modemmanager', method: 'restart_modem' });
var callRestartWan   = rpc.declare({ object: 'luci.modemmanager', method: 'restart_wan' });
var callDiagUsb      = rpc.declare({ object: 'luci.modemmanager', method: 'diag_usb' });
var callDiagPorts    = rpc.declare({ object: 'luci.modemmanager', method: 'diag_ports' });
var callDiagMmcli    = rpc.declare({ object: 'luci.modemmanager', method: 'diag_mmcli' });

var LTE_FREQ = {
	'1':'2100 MHz','2':'1900 MHz','3':'1800 MHz','4':'1700 MHz','5':'850 MHz',
	'7':'2600 MHz','8':'900 MHz','12':'700 MHz','13':'700 MHz','17':'700 MHz',
	'18':'850 MHz','19':'850 MHz','20':'800 MHz','26':'850 MHz','28':'700 MHz',
	'32':'1500 MHz','38':'2600 MHz','39':'1900 MHz','40':'2300 MHz','41':'2500 MHz',
	'42':'3500 MHz','43':'3700 MHz','48':'3500 MHz'
};

var NR_FREQ = {
	'1':'2100 MHz','3':'1800 MHz','5':'850 MHz','7':'2600 MHz','8':'900 MHz',
	'20':'800 MHz','28':'700 MHz','38':'2600 MHz','40':'2300 MHz','41':'2500 MHz',
	'77':'3700 MHz','78':'3500 MHz','79':'4700 MHz','257':'28 GHz','258':'26 GHz'
};

function detectSIMBrand(sim) {
	if (!sim) return '-';
	var spn = String(sim.op_name || '').toUpperCase().trim();
	var code = String(sim.op_code || '').trim();
	if (spn.indexOf('VERY') !== -1) return 'Very Mobile';
	if (spn.indexOf('HO') !== -1) return 'ho. Mobile';
	if (spn.indexOf('KENA') !== -1) return 'Kena Mobile';
	if (spn.indexOf('ILIAD') !== -1) return 'Iliad';
	if (spn.indexOf('COOP') !== -1) return 'CoopVoce';
	if (spn.indexOf('POSTE') !== -1) return 'PosteMobile';
	if (spn.indexOf('FASTWEB') !== -1) return 'Fastweb Mobile';
	if (spn.indexOf('LYCA') !== -1) return 'Lycamobile';
	if (code === '22288' || code === '22299') return 'Wind Tre';
	if (code === '22201') return 'TIM';
	if (code === '22210' || code === '22206') return 'Vodafone IT';
	if (code === '22250') return 'Iliad';
	return sim.op_name || code || '-';
}

function detectNetworkBrand(opName, opCode) {
	var name = String(opName || '').toUpperCase().trim();
	var code = String(opCode || '').trim();
	if (code === '22288' || code === '22299' || name.indexOf('WIND') !== -1 || name.indexOf('3 ITA') !== -1)
		return 'Wind Tre';
	if (code === '22201' || name.indexOf('TIM') !== -1) return 'TIM';
	if (code === '22210' || code === '22206' || name.indexOf('VODAFONE') !== -1) return 'Vodafone IT';
	if (code === '22250' || name.indexOf('ILIAD') !== -1) return 'Iliad';
	return opName || opCode || '-';
}

function esc(v) {
	return (v === undefined || v === null || v === '' || v === '--') ? '-' : String(v);
}

function row(label, value) {
	return E('tr', { 'class': 'tr' }, [
		E('td', { 'class': 'td left', 'width': '35%' }, label),
		E('td', { 'class': 'td left' }, value)
	]);
}

function sigColor(pct) {
	pct = parseInt(pct || 0, 10);
	if (pct >= 70) return '#28a745';
	if (pct >= 40) return '#ffc107';
	return '#dc3545';
}

function signalBar(pct) {
	pct = parseInt(pct || 0, 10);
	return E('span', {}, [
		pct + ' % ',
		E('span', {
			'style': 'display:inline-block;background:#eee;border-radius:6px;height:14px;width:180px;overflow:hidden;vertical-align:middle;margin-left:6px;'
		}, [
			E('span', { 'style': 'display:block;background:' + sigColor(pct) + ';width:' + pct + '%;height:100%;' })
		])
	]);
}

function parseNum(v) {
	if (v === undefined || v === null) return null;
	var s = String(v).trim();
	if (!s || s === '--' || s === '-') return null;
	var n = parseFloat(s.replace(',', '.'));
	return isNaN(n) ? null : n;
}

function clamp(n, min, max) {
	if (n < min) return min;
	if (n > max) return max;
	return n;
}

function fmtDb(n, unit) {
	if (n === null) return '-';
	return n.toFixed(2) + ' ' + unit;
}

function classifyMetric(kind, n) {
	if (n === null) return { label: '-', color: '#adb5bd', pct: 0 };
	var label, color, pct;
	if (kind === 'rssi') {
		pct = Math.round(((n - (-110)) / 70) * 100);
		if (n >= -65) { label = _('Excellent'); color = '#28a745'; }
		else if (n >= -75) { label = _('Good'); color = '#7cb342'; }
		else if (n >= -85) { label = _('Fair'); color = '#ffc107'; }
		else { label = _('Poor'); color = '#dc3545'; }
	} else if (kind === 'rsrp') {
		pct = Math.round(((n - (-140)) / 70) * 100);
		if (n >= -80) { label = _('Excellent'); color = '#28a745'; }
		else if (n >= -90) { label = _('Good'); color = '#7cb342'; }
		else if (n >= -100) { label = _('Fair'); color = '#ffc107'; }
		else { label = _('Poor'); color = '#dc3545'; }
	} else if (kind === 'rsrq') {
		pct = Math.round(((n - (-20)) / 17) * 100);
		if (n >= -10) { label = _('Excellent'); color = '#28a745'; }
		else if (n >= -15) { label = _('Good'); color = '#7cb342'; }
		else if (n >= -20) { label = _('Fair'); color = '#ffc107'; }
		else { label = _('Poor'); color = '#dc3545'; }
	} else {
		pct = Math.round((n / 30) * 100);
		if (n >= 20) { label = _('Excellent'); color = '#28a745'; }
		else if (n >= 13) { label = _('Good'); color = '#7cb342'; }
		else if (n >= 0) { label = _('Fair'); color = '#ffc107'; }
		else { label = _('Poor'); color = '#dc3545'; }
	}
	return { label: label, color: color, pct: clamp(pct, 0, 100) };
}

function meterRow(name, value, unit, kind) {
	var n = parseNum(value);
	var q = classifyMetric(kind, n);
	var text = n === null ? '-' : (fmtDb(n, unit) + '  ' + q.label);
	return E('div', { 'style': 'margin:8px 0 12px;' }, [
		E('div', { 'style': 'margin-bottom:4px;' }, [
			E('strong', { 'style': 'font-size:13px;' }, name + ' '),
			E('span', { 'style': 'font-family:monospace;font-size:13px;font-weight:700;color:' + q.color }, text)
		]),
		E('div', { 'style': 'background:#e9ecef;border-radius:8px;height:16px;overflow:hidden;' }, [
			E('span', { 'style': 'display:block;height:100%;width:' + q.pct + '%;background:' + q.color + ';' })
		])
	]);
}

function signalGraph(title, items) {
	var has = false;
	for (var i = 0; i < items.length; i++) {
		if (parseNum(items[i].value) !== null) { has = true; break; }
	}
	if (!has) return '-';
	var box = E('div', {
		'style': 'padding:10px 12px;border:1px solid #ddd;border-radius:10px;background:#f8f9fa;max-width:520px;'
	}, [
		E('div', { 'style': 'font-size:11px;color:#666;font-weight:600;margin-bottom:6px;' }, title)
	]);
	for (var j = 0; j < items.length; j++)
		box.appendChild(meterRow(items[j].name, items[j].value, items[j].unit, items[j].kind));
	return box;
}

function rpcFail(e) {
	ui.hideModal();
	ui.addNotification(null, E('p', {}, _('RPC error: ') + (e && (e.message || e))), 'error');
}

function parseBand(raw) {
	raw = String(raw || '').toLowerCase().trim();
	var m;
	if ((m = raw.match(/^eutran[-_]?(\d+)$/)))
		return { raw: raw, id: 'B' + m[1], num: m[1], tech: 'lte', freq: LTE_FREQ[m[1]] || ('LTE ' + m[1]) };
	if ((m = raw.match(/^ngran[-_]?(\d+)$/)))
		return { raw: raw, id: 'n' + m[1], num: m[1], tech: 'nr', freq: NR_FREQ[m[1]] || ('NR n' + m[1]) };
	if ((m = raw.match(/^utran[-_]?(\d+)$/)))
		return { raw: raw, id: 'U' + m[1], num: m[1], tech: 'umts', freq: 'UMTS ' + m[1] };
	if (raw === 'egsm' || raw === 'dcs' || raw === 'pcs' || raw === 'g850')
		return { raw: raw, id: raw.toUpperCase(), num: '0', tech: 'gsm', freq: '2G' };
	return null;
}

function sortBands(a, b) {
	var pa = parseBand(a), pb = parseBand(b);
	if (!pa || !pb) return 0;
	var order = { gsm: 0, umts: 1, lte: 2, nr: 3 };
	if (order[pa.tech] !== order[pb.tech]) return order[pa.tech] - order[pb.tech];
	return parseInt(pa.num, 10) - parseInt(pb.num, 10);
}

function createTabs(tabs) {
	var nav = E('ul', { 'class': 'cbi-tabmenu' });
	var content = E('div', { 'class': 'cbi-tabcontainer', 'style': 'padding-top:12px;' });

	function show(idx) {
		var kids = nav.children;
		for (var i = 0; i < kids.length; i++)
			kids[i].className = (i === idx) ? 'cbi-tab' : 'cbi-tab-disabled';
		while (content.firstChild) content.removeChild(content.firstChild);
		content.appendChild(tabs[idx].render());
	}

	for (var t = 0; t < tabs.length; t++) {
		(function (idx) {
			var li = E('li', {
				'class': idx === 0 ? 'cbi-tab' : 'cbi-tab-disabled',
				'click': function (ev) {
					ev.preventDefault();
					show(idx);
				}
			}, [ E('a', { 'href': '#' }, tabs[idx].title) ]);
			nav.appendChild(li);
		})(t);
	}

	show(0);
	return E('div', {}, [ nav, content ]);
}

function renderModems(data) {
	var wrap = E('div', {});

	if (!data || !data.installed) {
		wrap.appendChild(E('div', { 'class': 'alert-message error' }, _('ModemManager (mmcli) is not installed.')));
		return wrap;
	}
	if (!data.modem_present) {
		wrap.appendChild(E('div', { 'class': 'alert-message warning' }, _('No modem detected.')));
		return wrap;
	}

	var simBrand = data.sim ? detectSIMBrand(data.sim) : '-';
	var networkOperator = detectNetworkBrand(data.operator_name, data.operator_code);

	wrap.appendChild(E('h3', {}, _('General Information')));
	var t1 = E('table', { 'class': 'table cbi-section-table' });
	t1.appendChild(row(_('Signal strength'), signalBar(data.signal_quality)));
	t1.appendChild(row(_('SIM Operator'), simBrand));
	t1.appendChild(row(_('Registered Network'), networkOperator + ' (' + esc(data.operator_code) + ')'));
	t1.appendChild(row(_('SIM status'), data.sim
		? ((data.sim.active === 'yes' ? _('Active') : _('Inactive')) +
			' — IMSI: ' + esc(data.sim.imsi) + ' — ICCID: ' + esc(data.sim.iccid))
		: '-'));
	t1.appendChild(row(_('Registration'), esc(data.reg_state)));
	t1.appendChild(row(_('State'), esc(data.state) + (data.state_reason ? ' (' + data.state_reason + ')' : '')));
	t1.appendChild(row(_('Technology'), esc(data.access_tech).toUpperCase()));
	wrap.appendChild(t1);

	wrap.appendChild(E('h3', {}, _('Modem Information')));
	var t2 = E('table', { 'class': 'table cbi-section-table' });
	t2.appendChild(row(_('Modem type'), ((data.manufacturer || '') + ' ' + (data.model || '')).trim() || '-'));
	t2.appendChild(row(_('Revision / Firmware'), esc(data.revision) + ' / ' + esc(data.hw_revision)));
	t2.appendChild(row(_('IMEI'), esc(data.imei)));
	t2.appendChild(row(_('Primary port'), esc(data.primary_port)));
	t2.appendChild(row(_('Ports'), (data.ports || []).join(', ') || '-'));
	wrap.appendChild(t2);

	wrap.appendChild(E('h3', {}, _('Cell / Signal Information')));
	var cell = data.cell || {}, sig = data.signal || {};
	var t3 = E('table', { 'class': 'table cbi-section-table' });
	t3.appendChild(row('MCC / MNC', esc(cell.mcc) + ' / ' + esc(cell.mnc)));
	t3.appendChild(row('TAC', esc(cell.tac)));
	t3.appendChild(row('LTE RSSI / RSRP / RSRQ / SNR',
		[sig.lte_rssi, sig.lte_rsrp, sig.lte_rsrq, sig.lte_snr].map(esc).join(' / ')));
	t3.appendChild(row(_('LTE signal graph'), signalGraph(_('LTE'), [
		{ name: 'RSSI', value: sig.lte_rssi, unit: 'dBm', kind: 'rssi' },
		{ name: 'RSRP', value: sig.lte_rsrp, unit: 'dBm', kind: 'rsrp' },
		{ name: 'RSRQ', value: sig.lte_rsrq, unit: 'dB', kind: 'rsrq' },
		{ name: 'SNR', value: sig.lte_snr, unit: 'dB', kind: 'snr' }
	])));
	t3.appendChild(row('5G RSRP / RSRQ / SNR',
		[sig.nr5g_rsrp, sig.nr5g_rsrq, sig.nr5g_snr].map(esc).join(' / ')));

	var curLabels = [];
	var cb = data.current_bands || [];
	for (var i = 0; i < cb.length; i++) {
		var p = parseBand(cb[i]);
		curLabels.push(p ? p.id : cb[i]);
	}
	t3.appendChild(row(_('Current bands'), curLabels.join(' + ') || '-'));
	wrap.appendChild(t3);

	return wrap;
}

function makeBadge(info, selected) {
	return E('button', {
		'type': 'button',
		'title': info.raw + ' — ' + info.freq,
		'data-raw': info.raw,
		'class': 'mm-band-btn',
		'style': [
			'display:inline-block',
			'margin:4px',
			'padding:10px 12px',
			'border-radius:8px',
			'border:2px solid ' + (selected ? '#1e7e34' : '#adb5bd'),
			'background:' + (selected ? '#28a745' : '#e9ecef'),
			'color:' + (selected ? '#ffffff' : '#495057'),
			'font-weight:700',
			'font-family:monospace',
			'font-size:14px',
			'cursor:pointer',
			'min-width:70px',
			'line-height:1.2',
			'vertical-align:top',
			'text-align:center',
			'box-shadow:' + (selected ? '0 0 0 2px rgba(40,167,69,.25)' : 'none')
		].join(';')
	}, [
		E('div', { 'style': 'font-size:15px;' }, info.id),
		E('div', { 'style': 'font-size:10px;font-weight:500;opacity:0.9;margin-top:3px;white-space:nowrap;' }, info.freq || '')
	]);
}

function styleBadge(btn, on) {
	btn.style.background = on ? '#28a745' : '#e9ecef';
	btn.style.color = on ? '#ffffff' : '#495057';
	btn.style.borderColor = on ? '#1e7e34' : '#adb5bd';
	btn.style.boxShadow = on ? '0 0 0 2px rgba(40,167,69,.25)' : 'none';
}

function renderBandsPanel(data, mode) {
	var wrap = E('div', {});
	var titles = {
		lte: _('LTE Bands Configuration'),
		sa:  _('5G SA Bands Configuration'),
		nsa: _('5G NSA Bands Configuration'),
		all: _('Bands Configuration')
	};

	wrap.appendChild(E('h3', {}, titles[mode] || _('Bands')));
	wrap.appendChild(E('p', { 'style': 'color:#666;font-size:12px;margin-top:-6px;' },
		_('Click a band to select/deselect. Green = selected (will be applied). Only bands reported by mmcli are shown.')));

	if (!data || !data.installed) {
		wrap.appendChild(E('div', { 'class': 'alert-message error' }, _('ModemManager not installed.')));
		return wrap;
	}
	if (!data.modem_present) {
		wrap.appendChild(E('div', { 'class': 'alert-message warning' }, _('No modem detected.')));
		return wrap;
	}

	function allow(raw) {
		var p = parseBand(raw);
		if (!p) return false;
		if (mode === 'lte') return p.tech === 'lte';
		if (mode === 'sa')  return p.tech === 'nr';
		if (mode === 'nsa') return p.tech === 'lte' || p.tech === 'nr';
		if (mode === 'all') return p.tech === 'lte' || p.tech === 'nr';
		return false;
	}

	var supported = [];
	var supSrc = data.supported_bands || [];
	for (var s = 0; s < supSrc.length; s++) {
		if (allow(supSrc[s])) supported.push(supSrc[s]);
	}
	supported.sort(sortBands);

	var current = [];
	var curSrc = data.current_bands || [];
	for (var c = 0; c < curSrc.length; c++) {
		if (allow(curSrc[c])) current.push(curSrc[c]);
	}

	if (!supported.length) {
		var msg = (mode === 'sa' || mode === 'nsa')
			? _('This modem does not expose 5G NR (ngran-*) bands. LTE-only module.')
			: _('This modem does not expose the requested bands.');
		wrap.appendChild(E('div', { 'class': 'alert-message notice' }, msg));
		return wrap;
	}

	var selected = {};
	for (var k = 0; k < current.length; k++) selected[current[k]] = true;

	var modemName = ((data.manufacturer || '') + ' ' + (data.model || '')).trim() || 'Modem';

	var liveIds = [];
	for (var li = 0; li < current.length; li++) {
		var lp = parseBand(current[li]);
		liveIds.push(lp ? lp.id : current[li]);
	}
	var liveBox = E('div', {
		'style': 'padding:10px 12px;margin:8px 0 12px 0;background:rgba(40,167,69,0.10);border:1px solid rgba(40,167,69,0.40);border-radius:8px;'
	}, [
		E('div', { 'style': 'font-size:11px;color:#666;font-weight:600;' }, _('Currently set on modem')),
		E('div', {
			'id': 'mm-live-current-' + mode,
			'style': 'font-size:18px;font-weight:800;color:#28a745;margin-top:4px;'
		}, liveIds.join(' + ') || '—')
	]);

	var grid = E('div', {
		'id': 'mm-band-grid-' + mode,
		'style': 'padding:4px 0 12px 0;line-height:normal;'
	});

	var buttons = {};

	function chosenRaws() {
		var out = [];
		for (var key in selected) {
			if (selected[key]) out.push(key);
		}
		out.sort(sortBands);
		return out;
	}

	function paint() {
		for (var raw in buttons) styleBadge(buttons[raw], !!selected[raw]);

		var ids = [];
		var raws = chosenRaws();
		for (var i = 0; i < raws.length; i++) {
			var p = parseBand(raws[i]);
			ids.push(p ? p.id : raws[i]);
		}

		var preview = document.getElementById('mm-selection-preview-' + mode);
		if (preview) preview.textContent = ids.length ? ids.join(' + ') : _('No band selected');

		var cmd = document.getElementById('mm-cmd-preview-' + mode);
		if (cmd) {
			cmd.textContent = raws.length
				? ('mmcli -m ' + (data.modem_index || '0') + ' --set-current-bands="' + raws.join('|') + '"')
				: '';
		}
	}

	for (var bi = 0; bi < supported.length; bi++) {
		(function (raw) {
			var info = parseBand(raw);
			if (!info) return;
			var btn = makeBadge(info, !!selected[raw]);
			btn.onclick = function () {
				if (selected[raw]) delete selected[raw];
				else selected[raw] = true;
				paint();
				return false;
			};
			buttons[raw] = btn;
			grid.appendChild(btn);
		})(supported[bi]);
	}

	var legend = E('div', { 'style': 'padding:0 0 12px 0;font-size:12px;color:#666;' }, [
		E('span', { 'style': 'display:inline-block;width:14px;height:14px;background:#28a745;border-radius:3px;vertical-align:middle;margin-right:6px;' }),
		_('Selected / active'),
		E('span', { 'style': 'display:inline-block;width:14px;height:14px;background:#e9ecef;border:1px solid #adb5bd;border-radius:3px;vertical-align:middle;margin:0 6px 0 16px;' }),
		_('Supported (click to enable)')
	]);

	var section = E('div', {
		'class': 'cbi-section',
		'style': 'border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:12px;background:#fff;'
	}, [
		E('div', { 'style': 'font-weight:700;font-size:14px;margin-bottom:8px;' }, modemName),
		liveBox,
		grid,
		legend
	]);

	wrap.appendChild(section);

	var initIds = liveIds.slice();
	var summary = E('div', {
		'style': 'margin:12px 0;padding:12px;border:1px solid #ddd;border-radius:8px;background:#f8f9fa;'
	}, [
		E('div', { 'style': 'font-size:11px;color:#666;' }, _('Selection to apply')),
		E('div', {
			'id': 'mm-selection-preview-' + mode,
			'style': 'font-size:16px;font-weight:700;margin-top:4px;'
		}, initIds.length ? initIds.join(' + ') : _('No band selected')),
		E('code', {
			'id': 'mm-cmd-preview-' + mode,
			'style': 'display:block;margin-top:6px;font-size:11px;color:#666;white-space:pre-wrap;'
		}, '')
	]);
	wrap.appendChild(summary);

	var btnAll = E('button', {
		'class': 'btn cbi-button cbi-button-action',
		'type': 'button',
		'style': 'margin:4px 6px 4px 0;'
	}, _('Select all'));
	btnAll.onclick = function () {
		for (var i = 0; i < supported.length; i++) selected[supported[i]] = true;
		paint();
		return false;
	};

	var btnNone = E('button', {
		'class': 'btn cbi-button',
		'type': 'button',
		'style': 'margin:4px 6px 4px 0;'
	}, _('Deselect all'));
	btnNone.onclick = function () {
		selected = {};
		paint();
		return false;
	};

	var btnApply = E('button', {
		'class': 'btn cbi-button cbi-button-save important',
		'type': 'button',
		'style': 'margin:4px 6px 4px 0;color:#28a745;border-color:#28a745;'
	}, _('Apply changes'));
	btnApply.onclick = function () {
		var raws = chosenRaws();
		if (!raws.length) {
			ui.addNotification(null, E('p', {}, _('Select at least one band.')), 'warning');
			return false;
		}
		var arg = raws.join('|');
		ui.showModal(_('Applying bands'), [ E('p', { 'class': 'spinning' }, arg) ]);
		return callSetBands(arg, mode).then(function (r) {
			ui.hideModal();
			if (r && r.ok) {
				ui.addNotification(null, E('p', {}, _('Bands applied: ') + arg), 'info');
				window.setTimeout(function () { location.reload(); }, 1200);
			} else {
				ui.addNotification(null, E('p', {}, _('Error: ') + ((r && r.error) || 'unknown')), 'error');
			}
		}, rpcFail);
	};

	var btnReset = E('button', {
		'class': 'btn cbi-button cbi-button-reset',
		'type': 'button',
		'style': 'margin:4px 6px 4px 0;color:#dc3545;border-color:#dc3545;'
	}, _('Restore (any)'));
	btnReset.onclick = function () {
		ui.showModal(_('Restoring'), [ E('p', { 'class': 'spinning' }, _('mmcli --set-current-bands=any')) ]);
		return callResetBands().then(function (r) {
			ui.hideModal();
			if (r && r.ok) {
				ui.addNotification(null, E('p', {}, _('Bands restored to auto (any).')), 'info');
				window.setTimeout(function () { location.reload(); }, 1200);
			} else {
				ui.addNotification(null, E('p', {}, _('Restore failed: ') + ((r && r.error) || '')), 'error');
			}
		}, rpcFail);
	};

	wrap.appendChild(E('div', { 'style': 'margin-top:8px;' }, [ btnAll, btnNone, btnApply, btnReset ]));
	paint();
	return wrap;
}

function diagBlock(title, cmd, fn) {
	var out = E('pre', {
		'style': 'background:#111;color:#0f0;padding:10px;max-height:400px;overflow:auto;font-size:12px;white-space:pre-wrap;'
	}, _('Click Run.'));
	var btn = E('button', { 'class': 'btn cbi-button cbi-button-action', 'type': 'button' }, _('Run'));
	btn.onclick = function () {
		out.textContent = _('Running...');
		return fn().then(function (r) {
			out.textContent = (r && r.output) ? r.output : _('No output.');
		}, function () {
			out.textContent = _('Error.');
		});
	};
	return E('div', { 'style': 'margin-bottom:16px;padding:10px;border:1px solid #ddd;border-radius:8px;' }, [
		E('h4', {}, title),
		E('code', {}, cmd),
		E('div', { 'style': 'margin:8px 0;' }, [ btn ]),
		out
	]);
}

function renderDiagnostics() {
	return E('div', {}, [
		E('h3', {}, _('Diagnostics')),
		diagBlock(_('USB devices'), 'cat /sys/kernel/debug/usb/devices', callDiagUsb),
		diagBlock(_('Modem ports'), 'ls /dev (tty/cdc/wwan)', callDiagPorts),
		diagBlock(_('mmcli dump'), 'mmcli -L / -m X / signal / location', callDiagMmcli)
	]);
}

function renderConfiguration() {
	var wrap = E('div', {});
	wrap.appendChild(E('h3', {}, _('Configuration')));

	var btnModem = E('button', {
		'class': 'btn cbi-button cbi-button-action',
		'type': 'button',
		'style': 'margin:4px 8px 4px 0;'
	}, _('Switch QMI / ModemManager'));
	btnModem.onclick = function () {
		ui.showModal(_('Switching QMI / ModemManager'), [
			E('p', { 'class': 'spinning' }, _('Detecting protocol and applying the other stack...'))
		]);
		return callRestartModem().then(function (res) {
			ui.hideModal();
			if (res && res.ok) {
				var msg = (res.from && res.to)
					? (_('Switched: ') + res.from + ' -> ' + res.to + (res.interface ? (' (' + res.interface + ')') : ''))
					: _('Modem restart requested.');
				ui.addNotification(null, E('p', {}, msg), 'info');
				window.setTimeout(function () { location.reload(); }, 2500);
			} else {
				ui.addNotification(null, E('p', {}, _('Error: ') + ((res && res.error) || 'unknown')), 'error');
			}
		}, rpcFail);
	};

	var btnWan = E('button', {
		'class': 'btn cbi-button',
		'type': 'button',
		'style': 'margin:4px 8px 4px 0;'
	}, _('Restart WAN'));
	btnWan.onclick = function () {
		ui.showModal(_('Restart WAN'), [ E('p', { 'class': 'spinning' }, _('Please wait...')) ]);
		return callRestartWan().then(function (res) {
			ui.hideModal();
			ui.addNotification(null, E('p', {}, _('WAN restart requested.') + (res && res.interface ? (' (' + res.interface + ')') : '')), 'info');
		}, rpcFail);
	};

	wrap.appendChild(E('div', { 'style': 'margin:12px 0;' }, [ btnModem, btnWan ]));

	var m = new form.Map('modemmanager', _('ModemManager settings'));
	var s = m.section(form.NamedSection, 'main', 'modemmanager', _('Main'));
	s.anonymous = true;
	var o = s.option(form.Value, 'modem_index', _('Modem index'));
	o.datatype = 'uinteger'; o.default = '0';
	o = s.option(form.Flag, 'auto_refresh', _('Auto refresh')); o.default = '1';
	o = s.option(form.Value, 'refresh_interval', _('Refresh interval (s)'));
	o.datatype = 'range(2,60)'; o.default = '5';

	m.render().then(function (el) { wrap.appendChild(el); });
	return wrap;
}

return view.extend({
	load: function () {
		return Promise.all([
			callStatus(),
			uci.load('modemmanager').catch(function () { return null; })
		]);
	},

	render: function (loaded) {
		var data = loaded[0] || {};

		var hasNR = false, hasLTE = false;
		var sb = data.supported_bands || [];
		for (var i = 0; i < sb.length; i++) {
			var b = String(sb[i]);
			if (b.indexOf('ngran-') === 0) hasNR = true;
			if (b.indexOf('eutran-') === 0) hasLTE = true;
		}

		var tabs = [
			{ title: _('Modem(s)'), render: function () { return renderModems(data); } }
		];

		if (hasLTE)
			tabs.push({ title: _('Preferred LTE bands'), render: function () { return renderBandsPanel(data, 'lte'); } });

		tabs.push({ title: _('Preferred 5G SA bands'), render: function () { return renderBandsPanel(data, 'sa'); } });
		tabs.push({ title: _('Preferred 5G NSA bands'), render: function () { return renderBandsPanel(data, 'nsa'); } });
		tabs.push({ title: _('Diagnostics'), render: function () { return renderDiagnostics(); } });
		tabs.push({ title: _('Configuration'), render: function () { return renderConfiguration(); } });

		var cap = [];
		if (hasLTE) cap.push('LTE');
		if (hasNR) cap.push('5G NR');
		if (!cap.length) cap.push(_('unknown'));

		return E('div', { 'class': 'cbi-map' }, [
			E('h2', {}, 'ModemManager'),
			E('div', { 'class': 'cbi-map-descr' },
				_('Graphic interface for mmcli') + ' — ' +
				((data.manufacturer || '') + ' ' + (data.model || '')).trim() +
				' — ' + _('Capabilities') + ': ' + cap.join(' + ')),
			createTabs(tabs)
		]);
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});