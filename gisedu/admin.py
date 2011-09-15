from django.contrib.gis import admin
from gisedu.models import GiseduIntegerField, GiseduCharField, GiseduBooleanField, GiseduReduceItem

admin.site.register(GiseduIntegerField, admin.GeoModelAdmin)
admin.site.register(GiseduCharField, admin.GeoModelAdmin)
admin.site.register(GiseduBooleanField, admin.GeoModelAdmin)
admin.site.register(GiseduReduceItem, admin.GeoModelAdmin)