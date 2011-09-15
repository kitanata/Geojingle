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
from gisedu.models import GiseduCharField, GiseduIntegerField, GiseduBooleanField

class GiseduPolygonItem(models.Model):
    filter = models.ForeignKey(GiseduFilters)
    item_name = models.CharField(max_length=254, null=True)
    item_type = models.CharField(max_length=254, null=True) #for dict fields
    the_geom = models.MultiPolygonField(null=True)
    objects = models.GeoManager()

    def __str__(self):
        return str(self.item_name) + " " + str(self.item_type)

    class Meta:
        db_table = u'gisedu_polygon_item'
        verbose_name_plural = "Polygon Items"

class GiseduPolygonItemCharField(models.Model):
    polygon = models.ForeignKey(GiseduPolygonItem)
    field = models.ForeignKey(GiseduCharField)

    def polygon__item_name(self):
        return str(self.polygon.item_name)

    def field__field_name(self):
        return str(self.field.field_name)

    def field__field_value(self):
        return str(self.field.field_value)

    def __str__(self):
        return str(self.polygon.item_name) + ": " + str(self.field)

    class Meta:
        db_table = u'gisedu_polygon_item_char_field'
        verbose_name_plural = "Polygon Character Fields"

class GiseduPolygonItemIntegerField(models.Model):
    polygon = models.ForeignKey(GiseduPolygonItem)
    field = models.ForeignKey(GiseduIntegerField)

    def polygon__item_name(self):
        return str(self.polygon.item_name)

    def field__field_name(self):
        return str(self.field.field_name)

    def field__field_value(self):
        return str(self.field.field_value)

    def __str__(self):
        return str(self.polygon.item_name) + ": " + str(self.field)

    class Meta:
        db_table = u'gisedu_polygon_item_integer_field'
        verbose_name_plural = "Polygon Integer Fields"

class GiseduPolygonItemBooleanField(models.Model):
    polygon = models.ForeignKey(GiseduPolygonItem)
    field = models.ForeignKey(GiseduBooleanField)

    def polygon__item_name(self):
        return str(self.polygon.item_name)

    def field__field_name(self):
        return str(self.field.field_name)

    def field__field_value(self):
        return str(self.field.field_value)

    def __str__(self):
        return str(self.polygon.item_name) + ": " + str(self.field)

    class Meta:
        db_table = u'gisedu_polygon_item_boolean_field'
        verbose_name_plural = "Polygon Boolean Fields"
