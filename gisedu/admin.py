from django.contrib.gis import admin
from gisedu.models import GiseduIntegerField, GiseduCharField, GiseduBooleanField, GiseduReduceItem
from point_objects.models import GiseduPointItem

class GiseduFieldAdmin(admin.GeoModelAdmin):
    list_display = ('field_name', 'field_value')
    list_filter = ('field_name', 'field_value')

class PointBooleanFieldInline(admin.TabularInline):
    model = GiseduPointItem.boolean_fields.through

class GisedBooleanFieldAdmin(admin.ModelAdmin):
    list_display = ('field_name', 'field_value')
    list_filter = ('field_name', 'field_value')

    inlines = [PointBooleanFieldInline]

admin.site.register(GiseduIntegerField, GiseduFieldAdmin)
admin.site.register(GiseduCharField, GiseduFieldAdmin)
admin.site.register(GiseduBooleanField, GisedBooleanFieldAdmin)
admin.site.register(GiseduReduceItem, admin.GeoModelAdmin)