from sqlalchemy import Column, String, Integer, Boolean, Text, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from app.db.session import Base


class User(Base):
    __tablename__ = "users"
    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    role = Column(String, nullable=False)
    auth_provider = Column(String, nullable=False)
    password_hash = Column(String, nullable=True)
    onboarding_completed = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())

    student = relationship("Student", back_populates="user", uselist=False)


class Student(Base):
    __tablename__ = "students"
    id = Column(String, ForeignKey("users.id"), primary_key=True)
    career = Column(String, nullable=False)
    cycle = Column(Integer, nullable=False)
    campus = Column(String, nullable=False)
    modality = Column(String, nullable=False)
    availability = Column(String)
    english_level = Column(String)
    linkedin_url = Column(String)
    cv_status = Column(String, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())

    user = relationship("User", back_populates="student")
    goals = relationship("StudentGoal", back_populates="student")
    skills = relationship("StudentSkill", back_populates="student")
    evidences = relationship("Evidence", back_populates="student")
    applications = relationship("Application", back_populates="student")


class Company(Base):
    __tablename__ = "companies"
    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    sector = Column(String, nullable=False)
    description = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())

    jobs = relationship("Job", back_populates="company")


class CompanyUser(Base):
    __tablename__ = "company_users"
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    company_id = Column(String, ForeignKey("companies.id"), nullable=False)
    position = Column(String)


class StudentGoal(Base):
    __tablename__ = "student_goals"
    id = Column(String, primary_key=True)
    student_id = Column(String, ForeignKey("students.id"), nullable=False)
    role_id = Column(String, nullable=False)
    target_role_name = Column(String, nullable=False)
    availability = Column(String)
    preferred_work_mode = Column(String)
    application_timeframe = Column(String)
    active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, server_default=func.now())

    student = relationship("Student", back_populates="goals")


class Skill(Base):
    __tablename__ = "skills"
    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    type = Column(String, nullable=False)
    category = Column(String)
    active = Column(Boolean, nullable=False, default=True)


class StudentSkill(Base):
    __tablename__ = "student_skills"
    id = Column(String, primary_key=True)
    student_id = Column(String, ForeignKey("students.id"), nullable=False)
    skill_id = Column(String, ForeignKey("skills.id"), nullable=False)
    level = Column(Integer, nullable=False)
    source = Column(String, nullable=False)
    updated_at = Column(DateTime, server_default=func.now())

    student = relationship("Student", back_populates="skills")
    skill = relationship("Skill")


class Evidence(Base):
    __tablename__ = "evidences"
    id = Column(String, primary_key=True)
    student_id = Column(String, ForeignKey("students.id"), nullable=False)
    title = Column(String, nullable=False)
    type = Column(String, nullable=False)
    context = Column(Text)
    actions = Column(Text, nullable=False)
    result = Column(Text, nullable=False)
    cv_bullet = Column(Text)
    star_story = Column(Text)
    source = Column(String, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())

    student = relationship("Student", back_populates="evidences")
    skills = relationship("EvidenceSkill", back_populates="evidence")


class EvidenceSkill(Base):
    __tablename__ = "evidence_skills"
    id = Column(String, primary_key=True)
    evidence_id = Column(String, ForeignKey("evidences.id"), nullable=False)
    skill_id = Column(String, ForeignKey("skills.id"), nullable=False)
    confidence = Column(Integer)

    evidence = relationship("Evidence", back_populates="skills")
    skill = relationship("Skill")


class Job(Base):
    __tablename__ = "jobs"
    id = Column(String, primary_key=True)
    company_id = Column(String, ForeignKey("companies.id"), nullable=False)
    role_id = Column(String)
    title = Column(String, nullable=False)
    modality = Column(String, nullable=False)
    location = Column(String, nullable=False)
    hours = Column(String)
    description = Column(Text, nullable=False)
    status = Column(String, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())

    company = relationship("Company", back_populates="jobs")
    requirements = relationship("JobRequirement", back_populates="job")
    applications = relationship("Application", back_populates="job")


class JobRequirement(Base):
    __tablename__ = "job_requirements"
    id = Column(String, primary_key=True)
    job_id = Column(String, ForeignKey("jobs.id"), nullable=False)
    skill_id = Column(String, ForeignKey("skills.id"), nullable=False)
    required_level = Column(Integer, nullable=False)
    importance = Column(String, nullable=False)

    job = relationship("Job", back_populates="requirements")
    skill = relationship("Skill")


class Application(Base):
    __tablename__ = "applications"
    id = Column(String, primary_key=True)
    student_id = Column(String, ForeignKey("students.id"), nullable=False)
    job_id = Column(String, ForeignKey("jobs.id"), nullable=False)
    status = Column(String, nullable=False)
    notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())

    student = relationship("Student", back_populates="applications")
    job = relationship("Job", back_populates="applications")
