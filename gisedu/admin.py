from django.contrib.gis import admin
from gisedu.models import GiseduReduceItem, GiseduStringAttributeOption

class GiseduStringAttributeOptionAdmin(admin.ModelAdmin):
    list_display = ['option', 'attribute_filter']
    list_filter = ['attribute_filter']

admin.site.register(GiseduStringAttributeOption, GiseduStringAttributeOptionAdmin)
admin.site.register(GiseduReduceItem, admin.ModelAdmin)