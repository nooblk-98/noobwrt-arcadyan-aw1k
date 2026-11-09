"use strict";
"require view";
"require fs";
"require ui";

function field(obj, path, fallback) {
	var cur = obj;
	for (var i = 0; i < path.length; i++) {
		if (cur == null || typeof cur !== 'object')
			return fallback;
		cur = cur[path[i]];
	}
	return (cur == null || cur === '') ? fallback : cur;
}

function notify(text, type) {
	ui.addNotification(null, E('p', {}, text), type || 'info');
}

return view.extend({
	load: function() {
		return Promise.all([
			fs.exec('/usr/bin/mmcli', [ '-m', '0', '-J' ]).catch(function() { return { stdout: '' }; }),
			fs.exec('/usr/bin/mm-bandlock', [ 'status' ]).catch(function() { return { stdout: '' }; }),
			fs.exec('/usr/bin/mmcli', [ '-L' ]).catch(function() { return { stdout: '' }; })
		]);
	},

	render: function(res) {
		var modem = null;
		try { modem = JSON.parse(res[0].stdout).modem; } catch (e) { modem = null; }

		var g = (modem && modem.generic) || {};
		var t = (modem && modem['3gpp']) || {};
		var eps = field(t, [ 'eps', 'initial-bearer', 'settings' ], {});
		var signal = field(g, [ 'signal-quality', 'value' ], '--');
		var status = (res[1] && res[1].stdout) ? res[1].stdout : ((res[2] && res[2].stdout) || _('No modem found.'));

		var rows = [
			[ _('Manufacturer'), field(g, [ 'manufacturer' ], '--') ],
			[ _('Model'), field(g, [ 'model' ], '--') ],
			[ _('Firmware'), field(g, [ 'firmware-revision' ], field(g, [ 'revision' ], '--')) ],
			[ _('IMEI'), field(t, [ 'imei' ], field(g, [ 'equipment-identifier' ], '--')) ],
			[ _('State'), field(g, [ 'state' ], '--') ],
			[ _('Power'), field(g, [ 'power-state' ], '--') ],
			[ _('Access technology'), (g['access-technologies'] || []).join(', ') || '--' ],
			[ _('Signal'), signal + ' %' ],
			[ _('Operator'), field(t, [ 'operator-name' ], '--') ],
			[ _('Registration'), field(t, [ 'registration-state' ], '--') ],
			[ _('Packet service'), field(t, [ 'packet-service-state' ], '--') ],
			[ _('APN'), field(eps, [ 'apn' ], '--') ],
			[ _('IP type'), field(eps, [ 'ip-type' ], '--') ],
			[ _('Primary port'), field(g, [ 'primary-port' ], '--') ],
			[ _('Ports'), (g.ports || []).join(', ') || '--' ]
		];

		var table = E('table', { 'class': 'table' }, rows.map(function(r) {
			return E('tr', { 'class': 'tr' }, [
				E('td', { 'class': 'td left', 'width': '30%' }, r[0]),
				E('td', { 'class': 'td left' }, r[1])
			]);
		}));

		var bands = (g['current-bands'] || []).join(', ') || '--';

		var buttons = E('div', { 'class': 'cbi-page-actions' }, [
			E('button', {
				'class': 'cbi-button cbi-button-action',
				'click': ui.createHandlerFn(this, function() {
					return fs.exec('/sbin/ifup', [ 'mmwan' ]).then(function() {
						notify(_('Reconnecting mmwan...'));
						setTimeout(function() { window.location.reload(); }, 2000);
					}).catch(function(e) {
						notify(String(e), 'danger');
					});
				})
			}, [ _('Reconnect') ]),
			E('button', {
				'class': 'cbi-button cbi-button-reset',
				'click': ui.createHandlerFn(this, function() {
					if (!confirm(_('Reset the modem? The internet will drop briefly.')))
						return;
					return fs.exec('/usr/bin/mmcli', [ '-m', '0', '--reset' ]).then(function() {
						notify(_('Modem reset requested.'));
					}).catch(function(e) {
						notify(String(e), 'danger');
					});
				})
			}, [ _('Reset modem') ]),
			E('a', {
				'class': 'cbi-button',
				'href': L.url('admin/modem/bandlock')
			}, [ _('Band Lock') ]),
			E('button', {
				'class': 'cbi-button',
				'click': function() { window.location.reload(); }
			}, [ _('Refresh') ])
		]);

		return E('div', {}, [
			E('h2', {}, [ _('ModemManager') ]),
			table,
			E('h3', {}, [ _('Current bands') ]),
			E('div', { 'style': 'max-height:12em;overflow:auto;margin-bottom:1em' }, bands),
			buttons,
			E('h3', {}, [ _('5G NSA and carrier aggregation') ]),
			E('pre', { 'style': 'white-space:pre-wrap;margin:0' }, status)
		]);
	}
});
