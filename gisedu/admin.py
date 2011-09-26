from django.contrib.gis import admin
from gisedu.models import GiseduIntegerAttribute, GiseduStringAttribute, GiseduReduceItem, GiseduBooleanAttribute, GiseduStringAttributeOption

class GiseduStringAttributeOptionAdmin(admin.ModelAdmin):
    list_display = ['option', 'attribute']
    list_filter = ['attribute']

admin.site.register(GiseduBooleanAttribute, admin.ModelAdmin)
admin.site.register(GiseduIntegerAttribute, admin.ModelAdmin)
admin.site.register(GiseduStringAttribute, admin.ModelAdmin)
admin.site.register(GiseduStringAttributeOption, GiseduStringAttributeOptionAdmin)
admin.site.register(GiseduReduceItem, admin.GeoModelAdmin)