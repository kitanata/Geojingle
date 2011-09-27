from django.contrib.gis.db import models
from filters.models import GiseduFilters
from gisedu.models import GiseduBooleanAttribute, GiseduIntegerAttribute, GiseduStringAttribute, GiseduStringAttributeOption

class GiseduPointItemAddress(models.Model):
    gid = models.IntegerField(primary_key=True)
    street_num = models.IntegerField()
    street_name = models.CharField(max_length=254)
    mail_stop = models.CharField(max_length=254)
    address_line_one = models.CharField(max_length=254)
    address_line_two = models.CharField(max_length=254)
    city = models.CharField(max_length=254)
    state = models.CharField(max_length=254)
    zip10 = models.CharField(max_length=254)

    def __str__(self):
        return str(self.address_line_one) + " " + str(self.city) + ", " + str(self.state)

    class Meta:
        db_table = u'gisedu_point_item_address'
        verbose_name_plural = "Educational Organization Addresses"

class GiseduPointItem(models.Model):
    filter = models.ForeignKey(GiseduFilters)
    item_name = models.CharField(max_length=254, null=True)
    item_type = models.CharField(max_length=254, null=True) #for dict fields
    item_address = models.ForeignKey(GiseduPointItemAddress)
    
    the_geom = models.PointField()
    objects = models.GeoManager()

    def __str__(self):
        return str(self.item_name) + " " + str(self.item_type)

    class Meta:
        db_table = u'gisedu_point_item'
        verbose_name_plural = "Point Items"

class GiseduPointItemBooleanFields(models.Model):
    point = models.ForeignKey(GiseduPointItem)
    attribute = models.ForeignKey(GiseduBooleanAttribute)
    value = models.BooleanField()

    def point__filter(self):
        return str(self.point.filter)

    def __str__(self):
        return str(self.point)

    class Meta:
        db_table = u'gisedu_point_item_boolean_fields'
        verbose_name_plural = "Point Boolean Attributes"

class GiseduPointItemIntegerFields(models.Model):
    point = models.ForeignKey(GiseduPointItem)
    attribute = models.ForeignKey(GiseduIntegerAttribute)
    value = models.IntegerField()

    def point__filter(self):
        return str(self.point.filter)

    def __str__(self):
        return str(self.point)

    class Meta:
        db_table = u'gisedu_point_item_integer_fields'
        verbose_name_plural = "Point Integer Attributes"


class GiseduPointItemStringFields(models.Model):
    point = models.ForeignKey(GiseduPointItem)
    attribute = models.ForeignKey(GiseduStringAttribute)
    option = models.ForeignKey(GiseduStringAttributeOption)

    def point__filter(self):
        return str(self.point.filter)

    def __str__(self):
        return str(self.point)

    class Meta:
        db_table = u'gisedu_point_item_string_fields'
        verbose_name_plural = "Point String Attributes"
