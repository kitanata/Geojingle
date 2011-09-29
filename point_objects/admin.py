from django.contrib.gis import admin as gis_admin
from django.contrib import admin
from django.forms.widgets import CheckboxSelectMultiple
from django.db.models import ManyToManyField
from point_objects.models import GiseduPointItemAddress, GiseduPointItem, GiseduPointItemBooleanFields, GiseduPointItemIntegerFields, GiseduPointItemStringFields

class GiseduPointItemAddressAdmin(gis_admin.GeoModelAdmin):
    list_display = ('address_line_one', 'city', 'state', 'zip10')
    search_fields = ['address_line_one', 'city', 'state', 'zip10']
    exclude = ['gid']

    list_filter = ('state',)

class GiseduPointItemBooleanFieldAdmin(gis_admin.GeoModelAdmin):
    list_display = ('point', 'point__filter', 'attribute_filter', 'value')
    list_filter = ('point__filter__description', 'attribute_filter', 'value')
    
    search_fields = ['point__item_name']

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

class GiseduPointItemBooleanFieldsInline(admin.TabularInline):
    model = GiseduPointItemBooleanFields

class GiseduPointItemIntegerFieldAdmin(gis_admin.GeoModelAdmin):
    list_display = ('point', 'point__filter', 'attribute_filter', 'value')
    list_filter = ('point__filter__description', 'attribute_filter', 'value')

    search_fields = ['point__item_name']

class GiseduPointItemIntegerFieldsInline(admin.TabularInline):
    model = GiseduPointItemIntegerFields

class GiseduPointItemStringFieldAdmin(gis_admin.GeoModelAdmin):
    list_display = ('point', 'point__filter', 'attribute_filter', 'option')
    list_filter = ('point__filter__description', 'attribute_filter', 'option')

    search_fields = ['point__item_name']

class GiseduPointItemStringFieldsInline(admin.TabularInline):
    model = GiseduPointItemStringFields

class GiseduPointItemAdmin(gis_admin.GeoModelAdmin):
    list_display = ('item_name', 'filter', 'item_type')
    list_filter = ('filter__description', 'item_type')

    inlines = [GiseduPointItemBooleanFieldsInline,
               GiseduPointItemIntegerFieldsInline,
               GiseduPointItemStringFieldsInline]

admin.site.register(GiseduPointItemAddress, GiseduPointItemAddressAdmin)
admin.site.register(GiseduPointItem, GiseduPointItemAdmin)
admin.site.register(GiseduPointItemBooleanFields, GiseduPointItemBooleanFieldAdmin)
admin.site.register(GiseduPointItemIntegerFields, GiseduPointItemIntegerFieldAdmin)
admin.site.register(GiseduPointItemStringFields, GiseduPointItemStringFieldAdmin)
