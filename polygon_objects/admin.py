from django.contrib.gis import admin
from polygon_objects.models import GiseduPolygonItem, GiseduPolygonItemCharField, GiseduPolygonItemIntegerField,\
                                    GiseduPolygonItemBooleanField

class GiseduPolygonItemFieldAdmin(admin.GeoModelAdmin):
    list_display = ('polygon__item_name', 'field__field_name', 'field__field_value')
    list_filter = ('polygon__filter__filter_name', 'field__field_name', 'field__field_value')

class GiseduPolygonIntegerItemFieldAdmin(admin.GeoModelAdmin):
    list_display = ('polygon__item_name', 'field__field_name', 'field__field_value')
    list_filter = ('polygon__filter__filter_name', 'field__field_name')

class GiseduPolygonItemAdmin(admin.GeoModelAdmin):
    list_display = ('item_name', 'filter', 'item_type')
    list_filter = ('filter', 'item_type')

admin.site.register(GiseduPolygonItem, GiseduPolygonItemAdmin)
admin.site.register(GiseduPolygonItemCharField, GiseduPolygonItemFieldAdmin)
admin.site.register(GiseduPolygonItemIntegerField, GiseduPolygonIntegerItemFieldAdmin)
admin.site.register(GiseduPolygonItemBooleanField, GiseduPolygonItemFieldAdmin)