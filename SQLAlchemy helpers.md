Posterior probability = 
```python
from sqlalchemy.orm import object_session

...

class Book(db.Model):
    ...

    @property
    def author(self):
        return object_session(self).get(Author, self.author_id)
```


```python
from flask_sqlalchemy import Model, SQLAlchemy
import sqlalchemy as sa
from sqlalchemy.ext.declarative import declared_attr, has_inherited_table

class IdModel(Model):
    @declared_attr
    def id(cls):
        for base in cls.__mro__[1:-1]:
            if getattr(base, '__table__', None) is not None:
                type = sa.ForeignKey(base.id)
                break
        else:
            type = sa.Integer

        return sa.Column(type, primary_key=True)

db = SQLAlchemy(model_class=IdModel)

class User(db.Model):
    name = db.Column(db.String)

class Employee(User):
    title = db.Column(db.String)
```

> The "mutually dependent foreign keys" document doesn't really apply to this case. What happens here is that B(A) requires a join from B to A, and then B.a requires a different one. Even though the conventions here make it clear which foreign key constraint is which, the mapper still needs them to be explicitly spelled out, that's like this:

```python
class B(A):
    __tablename__ = 'b'

    id = Column(Integer, ForeignKey('a.id'), primary_key=True)

    __mapper_args__ = {
        'polymorphic_identity': 'b',
        'inherit_condition': id == A.id

    }

    a_id = Column(Integer, ForeignKey('a.id'))
    a = relationship(
        'A',
        backref='b', primaryjoin=A.id == a_id, remote_side=A.id)
```


```python
from sqlalchemy import *
from sqlalchemy.orm import *
metadata = MetaData()

parentTypesTable = Table(
    'ParentTypes', metadata,
    Column('parentTypeId', Integer, primary_key=True),
    Column('name', String, unique=True)
)

parentsTable = Table(
    'Parents', metadata,
    Column('parentId', Integer, primary_key=True),
    Column('parentTypeId', Integer, ForeignKey('ParentTypes.parentTypeId'))
)

childrenTable = Table(
    'Children', metadata,
    Column('parentId', Integer, ForeignKey('Parents.parentId'), primary_key=True)
)

class ParentType(object): pass
class Parent(object): pass
class Child(Parent): pass

mapper(ParentType, parentTypesTable)
mapper(Parent, parentsTable,
    polymorphic_on= # How might I access ParentType's name column?
)
mapper(Child, childrenTable, inherits=Parent, polymorphic_identity="child")



```python
polymorphic_on=parentsTable.c.parentTypeId
```
```