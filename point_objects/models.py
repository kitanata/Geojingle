from django.contrib.gis.db import models
from filters.models import GiseduFilters
from gisedu.models import GiseduCharField, GiseduBooleanAttribute, GiseduIntegerAttribute

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
    string_fields = models.ManyToManyField(GiseduCharField)
    
    the_geom = models.PointField()
    objects = models.GeoManager()

    def __str__(self):
        return str(self.item_name) + " " + str(self.item_type)

    class Meta:
        db_table = u'gisedu_point_item_new'
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