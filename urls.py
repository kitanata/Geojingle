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

    (r'^list/(?P<list_type>\w+)', 'gisedu.views.list'),
    
    (r'^org_type_list/', 'organizations.views.org_type_list'),
    (r'^school_type_list/', 'schools.views.school_type_list'),
    (r'^school_itc_list/', 'schools.views.school_itc_list'),
    (r'^school_ode_list/', 'schools.views.school_ode_list'),

    (r'^org_list_by_type/(?P<type>\d+)/', 'organizations.views.org_list_by_type'),
    (r'^school_list_by_type/(?P<type>\d+)/', 'schools.views.school_list_by_type'),

    (r'^filter/(?P<filter_chain>(\w+\s?\W*)*\w+\W*)', 'filter.views.parse_filter'),

#    (r'^filter/schools_by_type/(?P<type_name>(\w+\s\W*)*\w+\W*)/', 'schools.views.schools_by_type'),
#    (r'^filter/county_by_name/(?P<county_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.filter_county_by_name'),
#    (r'^filter/org_by_type/(?P<type_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.filter_org_by_type'),
#    (r'^filter/org_by_name/(?P<org_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.filter_org_by_name'),
#    (r'^filter/school_district_by_name/(?P<name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.filter_school_district_by_name'),
#    (r'^intersect/org_type/(?P<org_type>(\w+\s\W*)*\w+\W*)/county_name/(?P<county_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.intersect_org_type__county_name'),
#    (r'^intersect/org_type/(?P<org_type>(\w+\s\W*)*\w+\W*)/school_district_name/(?P<school_district_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.intersect_org_type__school_district_name'),
)
