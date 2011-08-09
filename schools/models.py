from django.contrib.gis.db import models
from gisedu.models import OhioSchoolDistricts
from organizations.models import GiseduOrg, GiseduOrgAddress

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