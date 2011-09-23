# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#     * Rearrange models' order
#     * Make sure each model has one field with primary_key=True
# Feel free to rename the models, but don't rename db_table values or field names.
#
# Also note: You'll have to insert the output of 'django-admin.py sqlcustom [appname]'
# into your database.

from django.contrib.gis.db import models
from filters.models import GiseduFilters
from gisedu.models import GiseduCharField, GiseduIntegerField, GiseduBooleanAttribute

class GiseduPolygonItem(models.Model):
    filter = models.ForeignKey(GiseduFilters)
    item_name = models.CharField(max_length=254, null=True)
    item_type = models.CharField(max_length=254, null=True) #for dict fields
    integer_fields = models.ManyToManyField(GiseduIntegerField)
    string_fields = models.ManyToManyField(GiseduCharField)

    the_geom = models.MultiPolygonField(null=True)
    objects = models.GeoManager()

    def __str__(self):
        if self.item_type:
            return str(self.item_name) + " " + str(self.item_type)
        else:
            return str(self.item_name)

    class Meta:
        db_table = u'gisedu_polygon_item_new'
        verbose_name_plural = "Polygon Items"

class GiseduPolygonItemBooleanFields(models.Model):
    id = models.IntegerField(primary_key=True)
    polygon = models.ForeignKey(GiseduPolygonItem)
    attribute = models.ForeignKey(GiseduBooleanAttribute)
    value = models.BooleanField()

    def polygon__filter(self):
        return str(self.polygon.filter)

    class Meta:
        db_table = u'gisedu_polygon_item_boolean_fields'
        verbose_name_plural = "Polygon Boolean Attributes"