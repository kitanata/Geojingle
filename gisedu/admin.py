from django.contrib.gis import admin
from gisedu.models import GiseduIntegerAttribute, GiseduCharField, GiseduReduceItem, GiseduBooleanAttribute
from point_objects.models import GiseduPointItem

class GiseduFieldAdmin(admin.GeoModelAdmin):
    list_display = ('field_name', 'field_value')
    list_filter = ('field_name', 'field_value')

admin.site.register(GiseduBooleanAttribute, admin.ModelAdmin)
admin.site.register(GiseduIntegerAttribute, admin.ModelAdmin)
admin.site.register(GiseduCharField, GiseduFieldAdmin)
admin.site.register(GiseduReduceItem, admin.GeoModelAdmin)