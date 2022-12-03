from typing import Optional, Tuple

from sqlalchemy import (
    Column,
    ForeignKey,
    Integer,
    String,
    case,
    cast,
    create_engine,
    event,
    func,
    inspect,
)
from sqlalchemy.orm import Session, declarative_base, object_session, polymorphic_union

Base = declarative_base()


class ident_(str):

    """describe a composed identity.

    Using a string for easy conversion to a string SQL composition.
    """

    _tup: Tuple[int, Optional[int]]

    def __new__(cls, d1, d2=None):
        if callable(d2):
            d2 = d2()
        self = super().__new__(cls, f"{d1}, {d2 or ''}")
        self._tup = d1, d2
        return self

    def _as_tuple(self):
        return self._tup


class BaseBudget(Base):
    __tablename__ = "tbl_budgets"
    id = Column(Integer, primary_key=True)

    name = Column(String(50))
    budget_type = Column(String(50))
    type = Column(String(50))

    __mapper_args__ = {
        "polymorphic_on": cast(type, String)
        + ", "
        + cast(func.coalesce(budget_type, ""), String),
    }


class BudgetType(Base):
    __tablename__ = "tbl_budget_types"
    id = Column(Integer, primary_key=True)
    name = Column(String(50))

    def __repr__(self):
        return f"{self.__class__.__name__}(id={self.id}, name={self.name!r})"


class Budget(BaseBudget):
    ...

    budget_data = Column(String(50))

    __mapper_args__ = {
        "polymorphic_identity": ident_("budget"),
    }


class HCPBudget(Budget):
    BUDGETTYPE = "hcp"

    __mapper_args__ = {
        "polymorphic_identity": ident_("budget", BUDGETTYPE),
    }


class NDISBudget(Budget):
    BUDGETTYPE = "hcp"

    __mapper_args__ = {
        "polymorphic_identity": ident_("budget", BUDGETTYPE),
    }


class BudgetTemplate(BaseBudget):

    template_data = Column(String(50))

    __mapper_args__ = {
        "polymorphic_identity": ident_("template"),
    }


@event.listens_for(BaseBudget, "init", propagate=True)
def _setup_poly(target, args, kw):
    """receive new BaseBudget objects when they are constructed and
    set polymorphic identity"""

    # this is the ident_() object
    ident = inspect(target).mapper.polymorphic_identity

    type, budget_type = ident._as_tuple()
    kw["type"] = type
    if budget_type:
        kw["budget_type"] = budget_type


e = create_engine("sqlite://", echo=True)
Base.metadata.create_all(e)
s = Session(e)
bt = BudgetType(name="hcp")
b = Budget(name="foo", budget_data="bar", budget_type="hcp")
hcp = HCPBudget(name="foo", budget_data="bar", budget_type="hcp")
ndis = NDISBudget(name="foo", budget_data="bar", budget_type="ndis")
t = BudgetTemplate(name="foo", template_data="bar")
s.add(b)
s.add(hcp)
s.add(t)
s.commit()
s.close()

assert len(s.query(HCPBudget).all()) == 2
