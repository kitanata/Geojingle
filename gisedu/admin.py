from django.contrib.gis import admin
from gisedu.models import GiseduFieldAttribute, GiseduReduceItem, GiseduStringAttributeOption

class GiseduStringAttributeOptionAdmin(admin.ModelAdmin):
    list_display = ['option', 'attribute']
    list_filter = ['attribute']

admin.site.register(GiseduFieldAttribute, admin.ModelAdmin)
admin.site.register(GiseduStringAttributeOption, GiseduStringAttributeOptionAdmin)
admin.site.register(GiseduReduceItem, admin.ModelAdmin)