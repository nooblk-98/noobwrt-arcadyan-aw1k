"use strict";
"require view";
"require form";
"require fs";
"require ui";

return view.extend({
	load: function() {
		return fs.exec('/usr/bin/mm-bandlock', [ 'status' ]).catch(function() {
			return { stdout: '', stderr: '' };
		});
	},

	render: function(res) {
		var status = (res && res.stdout) ? res.stdout : _('No ModemManager modem found.');
		var m = new form.Map('mm_bandlock', _('ModemManager band lock'),
			_('Lock the Quectel modem to selected LTE and 5G NR bands. Leave a list empty to skip that radio access technology.'));
		var s = m.section(form.NamedSection, 'main', 'main', _('Settings'));
		var o;

		s.anonymous = true;

		o = s.option(form.Flag, 'enabled', _('Apply at boot'));
		o.default = '0';
		o.rmempty = false;

		o = s.option(form.Value, 'lte', _('LTE bands'),
			_('Space-separated E-UTRAN band numbers, for example: 1 3 40'));
		o.placeholder = '1 3 5 7 8 40';

		o = s.option(form.Value, 'nr', _('5G NR bands'),
			_('Space-separated NR band numbers, for example: 78'));
		o.placeholder = '78';

		o = s.option(form.Button, '_apply', _('Apply saved bands now'));
		o.inputtitle = _('Apply');
		o.inputstyle = 'apply';
		o.onclick = function() {
			return fs.exec('/usr/bin/mm-bandlock', [ 'apply' ]).then(function(r) {
				if (r.code !== 0)
					throw new Error(r.stderr || r.stdout || _('Band lock failed.'));
				ui.addNotification(null, E('p', {}, r.stdout || _('Band lock applied.')));
				window.location.reload();
			}).catch(function(e) {
				ui.addNotification(null, E('p', {}, String(e)), 'danger');
			});
		};

		o = s.option(form.Button, '_unlock', _('Remove the band lock'));
		o.inputtitle = _('Unlock');
		o.inputstyle = 'reset';
		o.onclick = function() {
			return fs.exec('/usr/bin/mm-bandlock', [ 'unlock' ]).then(function(r) {
				if (r.code !== 0)
					throw new Error(r.stderr || r.stdout || _('Unlock failed.'));
				ui.addNotification(null, E('p', {}, r.stdout || _('Bands unlocked.')));
				window.location.reload();
			}).catch(function(e) {
				ui.addNotification(null, E('p', {}, String(e)), 'danger');
			});
		};

		return m.render().then(function(map) {
			return E('div', {}, [
				map,
				E('div', { 'class': 'cbi-section' }, [
					E('h3', {}, _('Modem status')),
					E('pre', { 'style': 'white-space:pre-wrap;margin:0' }, status)
				])
			]);
		});
	},

});
