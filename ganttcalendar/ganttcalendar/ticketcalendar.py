import re, calendar, time
from datetime import datetime, date, timedelta

from genshi.builder import tag

from trac.core import *
from trac.web import IRequestHandler
from trac.web.chrome import INavigationContributor, ITemplateProvider
from trac.util.datefmt import to_datetime, utc

class TicketCalendarPlugin(Component):
    implements(INavigationContributor, IRequestHandler, ITemplateProvider)

    # INavigationContributor methods
    def get_active_navigation_item(self, req):
        return 'ticketcalendar'
    
    def get_navigation_items(self, req):
        if req.perm.has_permission('TICKET_VIEW'):
             yield ('mainnav', 'ticketcalendar',
                    tag.a('Calendar', href=req.href.ticketcalendar()))
    
    # IRequestHandler methods
    def match_request(self, req):
        return re.match(r'/ticketcalendar(?:_trac)?(?:/.*)?$', req.path_info)

    def calendarRange(self, y, m):
       w,mdays = calendar.monthrange(y,m)
       w = (w + 1) % 7
       firstDay = date(y,m,1)-timedelta(days=w)
       
       lastDay = date(y,m,mdays)
       w = (lastDay.weekday()+1)%7
       lastDay = lastDay + timedelta(days=(6-w))
       return firstDay, lastDay

    def dateToString(self, dt):
       m = dt.month
       if m < 10:
          m = '0'+str(m)
       d = dt.day
       if d < 10:
          d = '0'+str(d)
       return str(dt.year)+"/"+str(m)+"/"+str(d)
    
    def process_request(self, req):
        ymonth = req.args.get('month')
        yyear = req.args.get('year')
        show_my_ticket = req.args.get('show_my_ticket')
        selected_milestone = req.args.get('selected_milestone')   
        cday = date.today()
        if not (not ymonth or not yyear):
            cday = date(int(yyear),int(ymonth),1)

        # cal next month
        nm = cday.month + 1
        ny  = cday.year
        if nm > 12:
            ny = ny + 1
            nm = 1
        nmonth = datetime(ny,nm,1)
        
        # cal previous month
        pm = cday.month - 1
        py = cday.year
        if pm < 1:
            py = py -1
            pm = 12
        pmonth = date(py,pm,1)
        first,last = self.calendarRange(cday.year, cday.month)
# process ticket
        db = self.env.get_db_cnx()
        cursor = db.cursor();
        my_ticket_sql = ""
        self.log.debug("myticket")
        self.log.debug(show_my_ticket)
        if show_my_ticket=="on":
            my_ticket_sql = "AND owner = '" + req.authname + "'"
        selected_milestone_sql = ""
        if selected_milestone != None and selected_milestone != "":
            selected_milestone_sql = "AND milestone = '" + selected_milestone  + "'"

        sql = ("SELECT id, type, summary, owner, description, status, a.value, c.value from ticket t "
                    "JOIN ticket_custom a ON a.ticket = t.id AND a.name = 'due_assign' "
                    "JOIN ticket_custom c ON c.ticket = t.id AND c.name = 'due_close' "
                    "WHERE ((a.value > '%s' AND a.value < '%s' ) "
                    "       OR (c.value > '%s' AND c.value < '%s')) %s %s" %
                    (self.dateToString(first),
                     self.dateToString(last),
                     self.dateToString(first),
                     self.dateToString(last),
                     my_ticket_sql,
                     selected_milestone_sql))

        self.log.debug(sql)
        cursor.execute(sql)
        tickets=[]
        for id, type, summary, owner, description, status, due_assign, due_close in cursor:
           due_assign_date = None
           due_close_date = None
           try:
              t = time.strptime(due_assign,"%Y/%m/%d")
              due_assign_date = date(t[0],t[1],t[2])
           except ValueError, TypeError:
              None
           try:
              t = time.strptime(due_close,"%Y/%m/%d")
              due_close_date = date(t[0],t[1],t[2])
           except ValueError, TypeError:
              None
           ticket = {'id':id, 'type':type, 'summary':summary, 'owner':owner, 'description': description, 'status':status, 'due_assign':due_assign_date, 'due_close':due_close_date}
           tickets.append(ticket)

        # get roadmap
        sql = ("SELECT name, due, completed, description from milestone")
        self.log.debug(sql)
        cursor.execute(sql)

        milestones = [""]
        for name, due, completed, description in cursor:
           if due!=0:
               due_time = to_datetime(due, utc)
               due_date = date(due_time.year, due_time.month, due_time.day)
               milestone = {'name':name, 'due':due_date, 'completed':completed != 0,'description':description}
               milestones.append(milestone)

        data = {'current':cday, 'prev':pmonth, 'next':nmonth, 'first':first, 'last':last, 'tickets':tickets, 'milestones':milestones, 
                'show_my_ticket': show_my_ticket, 'selected_milestone': selected_milestone}

        return 'calendar.html', data, None

    def get_templates_dirs(self):
        from pkg_resources import resource_filename
        return [resource_filename(__name__, 'templates')]

    def get_htdocs_dirs(self):
        from pkg_resources import resource_filename
        return [('tc', resource_filename(__name__, 'htdocs'))]
