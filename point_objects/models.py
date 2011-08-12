from django.contrib.gis.db import models
from gisedu.models import OhioSchoolDistricts

class GiseduOrgType(models.Model):
    gid = models.IntegerField(primary_key=True)
    org_type_name = models.CharField(max_length=254)

    def __str__(self):
        return str(self.org_type_name)

    class Meta:
        db_table = u'gisedu_org_type'
        verbose_name_plural = "Educational Organization Types"


class GiseduOrgAddress(models.Model):
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
        db_table = u'gisedu_org_address'
        verbose_name_plural = "Educational Organization Addresses"



class GiseduOrg(models.Model):
    gid = models.IntegerField(primary_key=True)
    org_key = models.IntegerField()
    org_nm = models.CharField(max_length=254)
    the_geom = models.PointField()
    address = models.ForeignKey(GiseduOrgAddress)
    org_type = models.ForeignKey(GiseduOrgType)
    building_irn = models.IntegerField()
    irn = models.IntegerField()
    objects = models.GeoManager()

    def __str__(self):
        return str(self.org_nm)

    class Meta:
        db_table = u'gisedu_org'
        verbose_name_plural = "Educational Organizations"



class SchoolAreaClassification(models.Model):
    gid = models.IntegerField(primary_key=True)
    classification = models.CharField(max_length=80)

    def __str__(self):
        return str(self.classification)

    class Meta:
        db_table = u'school_area_classification'



class SchoolItc(models.Model):
    gid = models.IntegerField(primary_key=True)
    itc = models.CharField(max_length=80)

    def __str__(self):
        return str(self.itc)

    class Meta:
        db_table = u'school_itc'



class Grade(models.Model):
    gid = models.IntegerField(primary_key=True)
    grade_num = models.IntegerField(unique=True)
    grade_name = models.CharField(max_length=80)

    def __str__(self):
        return str(self.grade_name)

    class Meta:
        db_table = u'grade'



class GiseduSchoolType(models.Model):
    gid = models.IntegerField(primary_key=True)
    school_type = models.CharField(max_length=254)

    def __str__(self):
        return str(self.school_type)

    class Meta:
        db_table = u'gisedu_school_type'



class GiseduSchoolInfo(models.Model):
    gid = models.IntegerField(primary_key=True)
    dirn = models.IntegerField()
    fte = models.IntegerField()
    adm = models.IntegerField()
    mbit = models.IntegerField()
    area_class = models.ForeignKey(SchoolAreaClassification)
    itc = models.ForeignKey(SchoolItc)
    school_district = models.ForeignKey(OhioSchoolDistricts)

    def __str__(self):
        return str(self.dirn)

    class Meta:
        db_table = u'gisedu_school_info'



class GiseduSchool(models.Model):
    gid = models.IntegerField(primary_key=True)
    building_info = models.ForeignKey(GiseduSchoolInfo)
    school_type = models.ForeignKey(GiseduSchoolType)
    school_name = models.CharField(max_length=254)
    irn = models.IntegerField()
    building_irn = models.IntegerField()
    address = models.ForeignKey(GiseduOrgAddress)
    grades = models.ManyToManyField(Grade)
    the_geom = models.PointField()
    objects = models.GeoManager()

    def __str__(self):
        return str(self.school_name)

    class Meta:
        db_table = u'gisedu_school'


class GiseduJointVocationalSchoolDistrict(models.Model):
    gid = models.IntegerField(primary_key=True)
    org_key = models.IntegerField()
    jvsd_name = models.CharField(max_length=254)
    the_geom = models.PointField()
    address = models.ForeignKey(GiseduOrgAddress)
    building_irn = models.IntegerField()
    irn = models.IntegerField()
    has_atomic_learning = models.BooleanField()
    objects = models.GeoManager()

    def __str__(self):
        return self.jvsd_name

    class Meta:
        db_table = u'gisedu_joint_vocational_school_district'