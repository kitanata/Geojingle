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

class GiseduIntegerAttribute(models.Model):
    attribute_name = models.CharField(max_length=254, null=True)

    def __str__(self):
        return str(self.attribute_name)

    class Meta:
        db_table = u'gisedu_integer_attribute'
        verbose_name_plural = "Integer Attributes"

class GiseduBooleanAttribute(models.Model):
    attribute_name = models.CharField(max_length=254)

    def __str__(self):
        return str(self.attribute_name)

    class Meta:
        db_table = u'gisedu_boolean_attribute'
        verbose_name_plural = "Boolean Attributes"

class GiseduStringAttribute(models.Model):
    attribute_name = models.CharField(max_length=254, null=True)

    def __str__(self):
        return str(self.attribute_name)

    class Meta:
        db_table = u'gisedu_string_attribute'
        verbose_name_plural = "String Attributes"

class GiseduStringAttributeOption(models.Model):
    attribute = models.ForeignKey(GiseduStringAttribute)
    option = models.CharField(max_length=254)

    def __str__(self):
        return str(self.option)

    class Meta:
        db_table = u'gisedu_string_attribute_option'
        verbose_name_plural = "String Attribute Options"

class GiseduReduceItem(models.Model):
    reduce_filter = models.ForeignKey(GiseduFilters, related_name='reduce_filter')
    target_filter = models.ForeignKey(GiseduFilters, related_name='target_filter')
    item_field = models.CharField(max_length=254, null=True)

    def __str__(self):
        return str(self.item_field)

    class Meta:
        db_table = u'gisedu_reduce_item'
        verbose_name_plural = "Reduce Items"

