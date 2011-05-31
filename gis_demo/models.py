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
    shape_area = models.DecimalField(max_digits=65536, decimal_places=65535)
    shape_len = models.DecimalField(max_digits=65536, decimal_places=65535)
    the_geom = models.MultiPolygonField(srid=4326)
    objects = models.GeoManager()

    class Meta:
        db_table = u'ohio_counties'
        verbose_name_plural = "Ohio Counties"

    def __str__(self):
        return str(self.name)



class OhioSchoolDistricts(models.Model):
    gid = models.IntegerField(primary_key=True)
    objectid = models.IntegerField()
    shape_leng = models.DecimalField(max_digits=65536, decimal_places=65535)
    ode_irn = models.CharField(max_length=6)
    name = models.CharField(max_length=51)
    lea_id = models.CharField(max_length=5)
    beg_grade = models.CharField(max_length=2)
    end_grade = models.CharField(max_length=2)
    taxid = models.CharField(max_length=4)
    id = models.CharField(max_length=6)
    area = models.DecimalField(max_digits=65536, decimal_places=65535)
    len = models.DecimalField(max_digits=65536, decimal_places=65535)
    pct_chg = models.DecimalField(max_digits=65536, decimal_places=65535)
    shape_area = models.DecimalField(max_digits=65536, decimal_places=65535)
    shape_len = models.DecimalField(max_digits=65536, decimal_places=65535)
    the_geom = models.MultiPolygonField(srid=4326)
    objects = models.GeoManager()
    class Meta:
        db_table = u'ohio_school_districts'
        verbose_name_plural = "Ohio School Districts"

    def __str__(self):
        return str(self.name)



class OhioEduOrgs(models.Model):
    gid = models.IntegerField(primary_key=True)
    objectid = models.IntegerField()
    org_key = models.IntegerField()
    irn = models.CharField(max_length=254)
    org_nm = models.CharField(max_length=254)
    ref_org_ty = models.IntegerField()
    org_typsd = models.CharField(max_length=254)
    st_num = models.IntegerField()
    st_nm = models.CharField(max_length=254)
    mail_stop = models.CharField(max_length=254)
    address1_o = models.CharField(max_length=254)
    address2_o = models.CharField(max_length=254)
    city_out = models.CharField(max_length=254)
    state_out = models.CharField(max_length=254)
    zip10_out = models.CharField(max_length=254)
    bldgirn = models.CharField(max_length=6)
    irn1 = models.CharField(max_length=6)
    the_geom = models.PointField(srid=3857)
    objects = models.GeoManager()

    class Meta:
        db_table = u'ohio_edu_orgs'
        verbose_name_plural = "Ohio Educational Organizations"

    def __str__(self):
        return str(self.org_nm)



class OhioLibraries(models.Model):
    gid = models.IntegerField(primary_key=True)
    objectid_1 = models.IntegerField()
    objectid = models.DecimalField(max_digits=65536, decimal_places=65535)
    name = models.CharField(max_length=100)
    address = models.CharField(max_length=150)
    city = models.CharField(max_length=50)
    state = models.CharField(max_length=50)
    zip = models.CharField(max_length=50)
    latitude = models.DecimalField(max_digits=65536, decimal_places=65535)
    longitude = models.DecimalField(max_digits=65536, decimal_places=65535)
    caicat = models.CharField(max_length=1)
    ref_org_ty = models.DecimalField(max_digits=65536, decimal_places=65535)
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