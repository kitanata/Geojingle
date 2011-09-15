from django.contrib.gis.db import models
from filters.models import GiseduFilters
from gisedu.models import GiseduCharField, GiseduIntegerField, GiseduBooleanField

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

    def __str__(self):
        return str(self.item_name) + " " + str(self.item_type)

    class Meta:
        db_table = u'gisedu_point_item'
        verbose_name_plural = "Point Items"

class GiseduPointItemCharField(models.Model):
    point = models.ForeignKey(GiseduPointItem)
    field = models.ForeignKey(GiseduCharField)

    def point__item_name(self):
        return str(self.point.item_name)

    def field__field_name(self):
        return str(self.field.field_name)

    def field__field_value(self):
        return str(self.field.field_value)

    def __str__(self):
        return str(self.point.item_name) + ": " + str(self.field)

    class Meta:
        db_table = u'gisedu_point_item_char_field'
        verbose_name_plural = "Point Character Fields"

class GiseduPointItemIntegerField(models.Model):
    point = models.ForeignKey(GiseduPointItem)
    field = models.ForeignKey(GiseduIntegerField)

    def point__item_name(self):
        return str(self.point.item_name)

    def field__field_name(self):
        return str(self.field.field_name)

    def field__field_value(self):
        return str(self.field.field_value)

    def __str__(self):
        return str(self.point.item_name) + ": " + str(self.field)

    class Meta:
        db_table = u'gisedu_point_item_integer_field'
        verbose_name_plural = "Point Integer Fields"

class GiseduPointItemBooleanField(models.Model):
    point = models.ForeignKey(GiseduPointItem)
    field = models.ForeignKey(GiseduBooleanField)

    def point__item_name(self):
        return str(self.point.item_name)

    def field__field_name(self):
        return str(self.field.field_name)

    def field__field_value(self):
        return str(self.field.field_value)
    
    def __str__(self):
        return str(self.point.item_name) + ": " + str(self.field)

    class Meta:
        db_table = u'gisedu_point_item_boolean_field'
        verbose_name_plural = "Point Boolean Fields"

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