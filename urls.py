from django.conf.urls.defaults import *

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Example:
    # (r'^Gis_Demo/', include('Gis_Demo.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    (r'^static/(?P<path>.*)$', 'django.views.static.serve',
        {'document_root': '/home/raymond/Projects/Python/Django/Gisedu/static'}),
    (r'^$', 'gisedu.views.index'),
    (r'^map/', 'gisedu.views.google_map'),
    (r'^admin/', include(admin.site.urls)),
    (r'^session/', 'session.views.session_request'),
    (r'^register/', 'session.views.register_request'),
    (r'^check_username/(?P<username>\w+)', 'session.views.check_user'),
    
    (r'^county/(?P<county_id>\d+)/', 'gisedu.views.county'),
    (r'^school_district/(?P<district_id>\d+)/', 'gisedu.views.school_district'),
    (r'^house_district/(?P<district_id>\d+)/', 'gisedu.views.house_district'),
    (r'^senate_district/(?P<district_id>\d+)/', 'gisedu.views.senate_district'),

    #Point Data
    (r'^org_geom/(?P<org_id>\d+)/', 'organizations.views.org_geom'),
    (r'^school_geom/(?P<school_id>\d+)/', 'schools.views.school_geom'),

    (r'^org_info/(?P<org_id>\d+)/', 'organizations.views.org_info'),

    (r'^org_infobox/(?P<org_id>\d+)/', 'organizations.views.org_infobox'),
    (r'^school_infobox/(?P<school_id>\d+)/', 'schools.views.school_infobox'),

    (r'^list/(?P<list_type>\w+)/type/(?P<type_id>\d+)', 'gisedu.views.list_by_type'),
    (r'^list/(?P<list_type>\w+)', 'gisedu.views.list'),

    (r'^school_itc_list/', 'schools.views.school_itc_list'),
    (r'^school_ode_list/', 'schools.views.school_ode_list'),

    (r'^filter/(?P<filter_chain>(\w+\s?\W*)*\w+\W*)', 'filter.views.parse_filter'),
)
