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
        {'document_root': '/home/raymond/Projects/Python/Django/Gis_Demo/static'}),
    (r'^$', 'gis_demo.views.index'),
    (r'^admin/', include(admin.site.urls)),
    (r'^json_test/', 'gis_demo.views.json_test'),
    (r'^county_list/', 'gis_demo.views.county_list'),
    (r'^county/(?P<county_id>\d+)/', 'gis_demo.views.county'),
)
