from django.contrib import admin
from django.contrib.gis import admin as geo_admin
from django.db import models
from django.forms.widgets import CheckboxSelectMultiple

from models import SchoolAreaClassification, SchoolItc, Grade, \
    GiseduSchoolType, GiseduSchoolInfo, GiseduSchool

class SchoolAreaClassificationAdmin(admin.ModelAdmin):
    list_display = ('classification',)
    search_fields = ['classification']
    exclude = ['gid']

class SchoolItcAdmin(admin.ModelAdmin):
    list_display = ('itc',)
    search_fields = ['itc']
    exclude = ['gid']

class GradeAdmin(admin.ModelAdmin):
    list_display = ('grade_name', 'grade_num',)
    search_fields = ['grade_name']
    exclude = ['gid']

class GiseduSchoolTypeAdmin(admin.ModelAdmin):
    list_display = ('school_type',)
    search_fields = ['school_type']
    exclude = ['gid']

class GiseduSchoolInfoAdmin(admin.ModelAdmin):
    list_display = ('dirn', 'mbit', 'area_class', 'itc')
    search_fields = ['dirn']
    exclude = ['gid', 'fte', 'adm']

    list_filter = ('mbit', 'area_class', 'itc')

class GiseduSchoolAdmin(geo_admin.GeoModelAdmin):
    list_display = ('school_name', 'building_info', 'school_type')
    search_fields = ['school_name', 'building_info__dirn']
    exclude = ['gid']

    formfield_overrides = {
        models.ManyToManyField: {'widget': CheckboxSelectMultiple},
    }

    list_filter = ('school_type', 'grades')

admin.site.register(SchoolAreaClassification, SchoolAreaClassificationAdmin)
admin.site.register(SchoolItc, SchoolItcAdmin)
admin.site.register(Grade, GradeAdmin)
admin.site.register(GiseduSchoolType, GiseduSchoolTypeAdmin)
admin.site.register(GiseduSchoolInfo, GiseduSchoolInfoAdmin)
admin.site.register(GiseduSchool, GiseduSchoolAdmin)