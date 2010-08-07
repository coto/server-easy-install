from setuptools import find_packages, setup

setup(
    name='TracGanttCalendarPlugin', version='0.1',
    packages=find_packages(exclude=['*.tests*']),
    entry_points = """
        [trac.plugins]
        ganttcalendar.ticketcalendar = ganttcalendar.ticketcalendar
        ganttcalendar.ticketgantt = ganttcalendar.ticketgantt
    """,
    package_data={'ganttcalendar': ['templates/*.html']},
)

#        ticketcalendar = ticketcalendar