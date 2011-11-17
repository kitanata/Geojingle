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

class GiseduStringAttributeOption(models.Model):
    """ Used by both PointObjectStringField and PolygonObjectStringField to hold possible strings that can be assigned to string attributes.
    """
    attribute_filter = models.ForeignKey(GiseduFilters)
    option = models.CharField(max_length=254)

    def __str__(self):
        return str(self.option)

    class Meta:
        db_table = u'gisedu_string_attribute_option'
        verbose_name_plural = "String Attribute Options"

class GiseduReduceItem(models.Model):
    """ This module maps attribute filters to all point and polygon filters that use them.
    """
    reduce_filter = models.ForeignKey(GiseduFilters, related_name='reduce_filter')
    target_filter = models.ForeignKey(GiseduFilters, related_name='target_filter')

    def __str__(self):
        return str(self.reduce_filter.description)

    class Meta:
        db_table = u'gisedu_reduce_item'
        verbose_name_plural = "Reduce Items"

