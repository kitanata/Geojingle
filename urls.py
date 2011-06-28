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
)
