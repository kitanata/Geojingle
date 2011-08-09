# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#     * Rearrange models' order
#     * Make sure each model has one field with primary_key=True
# Feel free to rename the models, but don't rename db_table values or field names.
#
# Also note: You'll have to insert the output of 'django-admin.py sqlcustom [appname]'
# into your database.

from django.contrib.gis.db import models

class OhioCounties(models.Model):
    gid = models.IntegerField(primary_key=True)
    objectid = models.IntegerField()
    cnty_fips = models.CharField(max_length=3)
    fips_num = models.IntegerField()
    cnty_code = models.CharField(max_length=3)
    cnty_num = models.IntegerField()
    name = models.CharField(max_length=16)
    cap_name = models.CharField(max_length=16)
    abbrev = models.CharField(max_length=3)
    shape_area = models.DecimalField(max_digits=1000, decimal_places=999)
    shape_len = models.DecimalField(max_digits=1000, decimal_places=999)
    the_geom = models.MultiPolygonField()
    objects = models.GeoManager()

    class Meta:
        db_table = u'ohio_counties'
        verbose_name_plural = "Ohio Counties"

    def __str__(self):
        return str(self.name)


class OhioSchoolDistricts(models.Model):
    gid = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=51)
    lea_id = models.CharField(max_length=5)
    beg_grade = models.CharField(max_length=2)
    end_grade = models.CharField(max_length=2)
    taxid = models.CharField(max_length=4)
    id = models.CharField(max_length=6)
    the_geom = models.MultiPolygonField()
    district_irn = models.IntegerField()
    comcast_coverage = models.BooleanField()
    has_atomic_learning = models.BooleanField()
    objects = models.GeoManager()

    class Meta:
        db_table = u'ohio_school_districts'
        verbose_name_plural = "Ohio School Districts"

    def __str__(self):
        return str(self.name)

class OhioHouseDistricts(models.Model):
    gid = models.IntegerField(primary_key=True)
    district = models.IntegerField()
    the_geom = models.MultiPolygonField()
    objects = models.GeoManager()

    class Meta:
        db_table = u'ohio_house_districts'
        verbose_name_plural = "Ohio House Districts"

    def __str__(self):
        return "House District " + str(self.district)

class OhioSenateDistricts(models.Model):
    gid = models.IntegerField(primary_key=True)
    district = models.IntegerField()
    the_geom = models.MultiPolygonField()
    objects = models.GeoManager()

    class Meta:
        db_table = u'ohio_senate_districts'
        verbose_name_plural = "Ohio Senate Districts"

    def __str__(self):
        return "Senate District " + str(self.district)

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
    the_geom = models.PointField(srid=3857)
    objects = models.GeoManager()

    class Meta:
        db_table = u'ohio_libraries'
        verbose_name_plural = "Ohio Libraries"

    def __str__(self):
        return str(self.name)
