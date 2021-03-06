from django.contrib.gis import admin
from polygon_objects.models import GiseduPolygonItem, GiseduPolygonItemBooleanFields, GiseduPolygonItemIntegerFields, GiseduPolygonItemStringFields

class GiseduPolygonItemBooleanFieldsInline(admin.TabularInline):
    model = GiseduPolygonItemBooleanFields

class GiseduPolygonItemBooleanFieldAdmin(admin.GeoModelAdmin):
    list_display = ('polygon', 'polygon__filter', 'attribute_filter', 'value')
    list_filter = ('polygon__filter__description', 'attribute_filter', 'value')
    
    search_fields = ['polygon__item_name']

    actions = ['set_field_true', 'set_field_false']

    def set_field_true(self, request, queryset):
        rows_updated = queryset.update(has_atomic_learning=True)
        if rows_updated == 1:
            message_bit = "1 Item was"
        else:
            message_bit = "%s Items were" % rows_updated
        self.message_user(request, "%s successfully marked. (Set to True)" % message_bit)

    def set_field_false(self, request, queryset):
        rows_updated = queryset.update(has_atomic_learning=False)
        if rows_updated == 1:
            message_bit = "1 Item was"
        else:
            message_bit = "%s Items were" % rows_updated
        self.message_user(request, "%s successfully un-marked. (Set to False)" % message_bit)

    set_field_true.short_description = "Mark selected Items. (Set to True)"
    set_field_false.short_description = "Un-mark selected Items. (Set to False)"

class GiseduPolygonItemIntegerFieldsInline(admin.TabularInline):
    model = GiseduPolygonItemIntegerFields

class GiseduPolygonItemIntegerFieldAdmin(admin.GeoModelAdmin):
    list_display = ('polygon', 'polygon__filter', 'attribute_filter', 'value')
    list_filter = ('polygon__filter__description', 'attribute_filter', 'value')

    search_fields = ['polygon__item_name', 'value']

class GiseduPolygonItemStringFieldsInline(admin.TabularInline):
    model = GiseduPolygonItemStringFields

class GiseduPolygonItemStringFieldAdmin(admin.GeoModelAdmin):
    list_display = ('polygon', 'polygon__filter', 'attribute_filter', 'option')
    list_filter = ('polygon__filter__description', 'attribute_filter', 'option')

    search_fields = ['polygon__item_name']

class GiseduPolygonItemAdmin(admin.GeoModelAdmin):
    list_display = ('item_name',)# 'filter', 'item_type')
    list_filter = ('filter', 'item_type')

    search_fields = ['item_name']

    inlines = [GiseduPolygonItemBooleanFieldsInline,
               GiseduPolygonItemIntegerFieldsInline,
               GiseduPolygonItemStringFieldsInline]

admin.site.register(GiseduPolygonItem, GiseduPolygonItemAdmin)
admin.site.register(GiseduPolygonItemBooleanFields, GiseduPolygonItemBooleanFieldAdmin)
admin.site.register(GiseduPolygonItemIntegerFields, GiseduPolygonItemIntegerFieldAdmin)
admin.site.register(GiseduPolygonItemStringFields, GiseduPolygonItemStringFieldAdmin)
