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
    (r'^admin/', include(admin.site.urls)),
    (r'^county/(?P<county_id>\d+)/', 'gisedu.views.county'),
    (r'^school_district/(?P<district_id>\d+)/', 'gisedu.views.school_district'),
    (r'^org_geom/(?P<org_id>\d+)/', 'gisedu.views.org_geom'),
    (r'^org_info/(?P<org_id>\d+)/', 'gisedu.views.org_info'),
    (r'^org_infobox/(?P<org_id>\d+)/', 'gisedu.views.org_infobox'),
    (r'^county_list/', 'gisedu.views.county_list'),
    (r'^school_district_list/', 'gisedu.views.school_district_list'),
    (r'^org_type_list/', 'gisedu.views.org_type_list'),
    (r'^org_list_by_typename/(?P<type_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.org_list_by_typename'),

    (r'^filter/county_by_name/(?P<county_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.filter_county_by_name'),
    (r'^filter/org_by_type/(?P<type_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.filter_org_by_type'),
    (r'^filter/org_by_name/(?P<org_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.filter_org_by_name'),
    (r'^filter/school_district_by_name/(?P<name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.filter_school_district_by_name'),

    (r'^intersect/org_type/(?P<org_type>(\w+\s\W*)*\w+\W*)/county_name/(?P<county_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.intersect_org_type__county_name'),
    (r'^intersect/org_type/(?P<org_type>(\w+\s\W*)*\w+\W*)/school_district_name/(?P<school_district_name>(\w+\s\W*)*\w+\W*)/', 'gisedu.views.intersect_org_type__school_district_name'),
)
