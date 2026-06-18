var panel = new Panel
panel.location = 'bottom';
panel.height = gridUnit * 2;

var kickoff = panel.addWidget('org.kde.plasma.kickoff');
kickoff.currentConfigGroup = ['General'];
kickoff.writeConfig('icon', 'start-here-turtlinux.svg'); 

panel.addWidget('org.kde.plasma.pager');

panel.addWidget('org.kde.plasma.icontasks');

panel.addWidget('org.kde.plasma.systemtray');

panel.addWidget('org.kde.plasma.digitalclock');

panel.addWidget('org.kde.plasma.showdesktop');