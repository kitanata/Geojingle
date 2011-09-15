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

class GiseduIntegerField(models.Model):
    field_name = models.CharField(max_length=254, null=True)
    field_value = models.IntegerField(null=True)

    class Meta:
        db_table = u'gisedu_integer_field'
        verbose_name_plural = "Integer Fields"

class GiseduCharField(models.Model):
    field_name = models.CharField(max_length=254, null=True)
    field_value = models.CharField(max_length=254, null=True)

    class Meta:
        db_table = u'gisedu_char_field'
        verbose_name_plural = "Character Fields"

class GiseduBooleanField(models.Model):
    field_name = models.CharField(max_length=254, null=True)
    field_value = models.BooleanField(default=False)

    class Meta:
        db_table = u'gisedu_boolean_field'
        verbose_name_plural = "Boolean Fields"

class GiseduPolygonItem(models.Model):
    filter = models.ForeignKey(GiseduFilters)
    item_name = models.CharField(max_length=254, null=True)
    item_type = models.CharField(max_length=254, null=True) #for dict fields
    the_geom = models.MultiPolygonField(null=True)
    objects = models.GeoManager()

    class Meta:
        db_table = u'gisedu_polygon_item'
        verbose_name_plural = "Polygon Items"

class GiseduPolygonItemCharField(models.Model):
    polygon = models.ForeignKey(GiseduPolygonItem)
    field = models.ForeignKey(GiseduCharField)

    class Meta:
        db_table = u'gisedu_polygon_item_char_field'
        verbose_name_plural = "Polygon Character Fields"

class GiseduPolygonItemIntegerField(models.Model):
    polygon = models.ForeignKey(GiseduPolygonItem)
    field = models.ForeignKey(GiseduIntegerField)

    class Meta:
        db_table = u'gisedu_polygon_item_integer_field'
        verbose_name_plural = "Polygon Integer Fields"

class GiseduPolygonItemBooleanField(models.Model):
    polygon = models.ForeignKey(GiseduPolygonItem)
    field = models.ForeignKey(GiseduBooleanField)

    class Meta:
        db_table = u'gisedu_polygon_item_boolean_field'
        verbose_name_plural = "Polygon Boolean Fields"

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
    the_geom = models.PointField(null=True)
    objects = models.GeoManager()

    class Meta:
        db_table = u'gisedu_point_item'
        verbose_name_plural = "Point Items"

class GiseduPointItemCharField(models.Model):
    point = models.ForeignKey(GiseduPointItem)
    field = models.ForeignKey(GiseduCharField)

    class Meta:
        db_table = u'gisedu_point_item_char_field'
        verbose_name_plural = "Point Character Fields"

class GiseduPointItemIntegerField(models.Model):
    point = models.ForeignKey(GiseduPointItem)
    field = models.ForeignKey(GiseduIntegerField)

    class Meta:
        db_table = u'gisedu_point_item_integer_field'
        verbose_name_plural = "Point Integer Fields"

class GiseduPointItemBooleanField(models.Model):
    point = models.ForeignKey(GiseduPointItem)
    field = models.ForeignKey(GiseduBooleanField)

    class Meta:
        db_table = u'gisedu_point_item_boolean_field'
        verbose_name_plural = "Point Boolean Fields"

class GiseduReduceItem(models.Model):
    reduce_filter = models.ForeignKey(GiseduFilters, related_name='reduce_filter')
    target_filter = models.ForeignKey(GiseduFilters, related_name='target_filter')
    item_field = models.CharField(max_length=254, null=True)

    class Meta:
        db_table = u'gisedu_reduce_item'
        verbose_name_plural = "Reduce Items"

class OhioLibraries(models.Model):
    gid = models.IntegerField(primary_key=True)
    objectid_1 = models.IntegerField()
    objectid = models.DecimalField(max_digits=1000, decimal_places=999)
    name = models.CharField(max_length=100)
    address = models.CharField(max_length=150)
    city = models.CharField(max_length=50)
    state = models.CharField(max_length=50)
    zip = models.CharField(max_length=50)
    latitude = models.DecimalField(max_digits=1000, decimal_places=999)
    longitude = models.DecimalField(max_digits=1000, decimal_places=999)
    caicat = models.CharField(max_length=1)
    ref_org_ty = models.DecimalField(max_digits=1000, decimal_places=999)
    bbservice = models.CharField(max_length=1)
    transtech = models.CharField(max_length=2)
    maxadvdown = models.CharField(max_length=2)
    maxadvup = models.CharField(max_length=2)
    identifier = models.CharField(max_length=40)
    email = models.CharField(max_length=50)
    telephone = models.CharField(max_length=50)
    id = models.CharField(max_length=16)
    odeirn = models.CharField(max_length=6)
    irnnum = models.IntegerField()
    match_cd = models.CharField(max_length=8)
    loc_qual = models.CharField(max_length=8)
    loc_conf = models.IntegerField()
    served = models.CharField(max_length=1)
    the_geom = models.PointField(srid=4326)
    objects = models.GeoManager()

    class Meta:
        db_table = u'ohio_libraries'
        verbose_name_plural = "Ohio Libraries"

    def __str__(self):
        return str(self.name)
