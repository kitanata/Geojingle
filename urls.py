from django.conf.urls.defaults import patterns, include, url
from django.contrib.staticfiles.urls import staticfiles_urlpatterns

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
import settings

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Example:
    # (r'^Gis_Demo/', include('Gis_Demo.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^$', 'gisedu.views.index'),
    url(r'^map/', 'gisedu.views.google_map'),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^session/', 'session.views.session_request'),
    url(r'^register/', 'session.views.register_request'),
    url(r'^check_username/(?P<username>\w+)', 'session.views.check_user'),

    url(r'^cloud/project_list/', 'cloud.views.project_list'),
    url(r'^cloud/project/(?P<project_name>(\w+\s?\W*)*\w+\W*)', 'cloud.views.project'),

    #Point Data
    url(r'^point_geom/(?P<data_type>\w+)/list/', 'point_objects.views.point_geom_list'),
    url(r'^point_infobox/(?P<data_type>\w+)/id/(?P<point_id>\d+)/', 'point_objects.views.point_infobox_by_type'),

    #Polygon Data
    url(r'^polygon_geom/(?P<data_type>\w+)/list/', 'polygon_objects.views.polygon_geom_list'),

    #Filter Data
    url(r'^filter_list', 'filters.views.filter_list'),
    url(r'^filter/(?P<filter_chain>(\w+\s?\W*)*\w+\W*)', 'filters.views.parse_filter'),

    #Data Import Processors
    url(r'^upload_csv', 'data_import.views.upload_csv'),
    url(r'^import_csv', 'data_import.views.import_csv'),
)

if settings.DEBUG:
    urlpatterns += staticfiles_urlpatterns()
