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
from gisedu.models import GiseduStringAttributeOption

class GiseduPolygonItem(models.Model):
    """ The model associated with all polygon items in the postGIS database. """
    filter = models.ForeignKey(GiseduFilters)
    item_name = models.CharField(max_length=254, null=True)
    item_type = models.CharField(max_length=254, null=True) #for dict fields

    the_geom = models.MultiPolygonField(null=True)
    objects = models.GeoManager()

    def __str__(self):
        if self.item_type:
            return str(self.item_name) + " " + str(self.item_type)
        else:
            return str(self.item_name)

    class Meta:
        db_table = u'gisedu_polygon_item'
        verbose_name_plural = "Polygon Items"

class GiseduPolygonItemBooleanFields(models.Model):
    """ Boolean attribute fields associated with polygon items. """
    polygon = models.ForeignKey(GiseduPolygonItem)
    attribute_filter = models.ForeignKey(GiseduFilters)
    value = models.BooleanField()

    def polygon__filter(self):
        return str(self.polygon.filter)

    class Meta:
        db_table = u'gisedu_polygon_item_boolean_fields'
        verbose_name_plural = "Polygon Boolean Attributes"

class GiseduPolygonItemIntegerFields(models.Model):
    """ Integer attribute fields associated with polygon items. """
    polygon = models.ForeignKey(GiseduPolygonItem)
    attribute_filter = models.ForeignKey(GiseduFilters)
    value = models.IntegerField()

    def polygon__filter(self):
        return str(self.polygon.filter)

    def __str__(self):
        return str(self.polygon)

    class Meta:
        db_table = u'gisedu_polygon_item_integer_fields'
        verbose_name_plural = "Polygon Integer Attributes"

class GiseduPolygonItemStringFields(models.Model):
    """ String attribute fields associated with polygon items. """
    polygon = models.ForeignKey(GiseduPolygonItem)
    attribute_filter = models.ForeignKey(GiseduFilters)
    option = models.ForeignKey(GiseduStringAttributeOption)

    def polygon__filter(self):
        return str(self.polygon.filter)

    def __str__(self):
        return str(self.polygon)

    class Meta:
        db_table = u'gisedu_polygon_item_string_fields'
        verbose_name_plural = "Polygon String Attributes"