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

    (r'^cloud/project_list/', 'cloud.views.project_list'),
    (r'^cloud/project/(?P<project_name>(\w+\s?\W*)*\w+\W*)', 'cloud.views.project'),

    #Point Data
    (r'^point_geom/(?P<data_type>\w+)/list/', 'point_objects.views.point_geom_list'),
    (r'^point_info/(?P<data_type>\w+)/id/(?P<point_id>\d+)/', 'point_objects.views.point_info_by_type'),
    (r'^point_infobox/(?P<data_type>\w+)/id/(?P<point_id>\d+)/', 'point_objects.views.point_infobox_by_type'),

    #Polygon Data
    (r'^polygon_geom/(?P<data_type>\w+)/list/', 'polygon_objects.views.polygon_geom_list'),

    #Filter Data
    (r'^filter_list', 'filters.views.filter_list'),
    (r'^filter/(?P<filter_chain>(\w+\s?\W*)*\w+\W*)', 'filters.views.parse_filter'),
)
