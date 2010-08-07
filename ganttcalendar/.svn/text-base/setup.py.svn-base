from setuptools import find_packages, setup

setup(
    name='TracGanttCalendarPlugin', version='0.1',
    packages=find_packages(exclude=['*.tests*']),

    author = "Takashi Okamoto",
    author_email='okamototk@user.sourceforge.jp',
    url="http://sourceforge.jp/projects/shibuya-trac/",
    description='Provide calendar and ganttchart.',
    license = "New BSD",

    entry_points = """
        [trac.plugins]
        ganttcalendar.ticketcalendar = ganttcalendar.ticketcalendar
        ganttcalendar.ticketgantt = ganttcalendar.ticketgantt
    """,
    package_data={'ganttcalendar': ['templates/*.html','htdocs/img/*']},
)

#        ticketcalendar = ticketcalendar