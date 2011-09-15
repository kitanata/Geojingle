from django.contrib import admin
from filters.models import GiseduFilters

admin.site.register(GiseduFilters, admin.ModelAdmin)