from django.contrib.gis import admin
from polygon_objects.models import GiseduPolygonItem

class GiseduPolygonItemAdmin(admin.GeoModelAdmin):
    list_display = ('item_name', 'filter', 'item_type')
    list_filter = ('filter', 'item_type')

admin.site.register(GiseduPolygonItem, GiseduPolygonItemAdmin)