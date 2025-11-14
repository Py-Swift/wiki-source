# Expanded Type Support

## Overview

When you mark classes with `@PyClass`, they automatically gain the ability to be passed between Python and Swift. This document explains how PySwiftKit handles custom class serialization and how to use arrays and dictionaries of custom types.

## Serialization Protocols

PySwiftKit uses two core protocols for converting between Python and Swift:

### PyDeserialize (Python → Swift)

```swift
public protocol PyDeserialize {
    static func casted(from object: PyPointer) throws -> Self
    static func casted(unsafe object: PyPointer) throws -> Self
}
```

This protocol handles converting Python objects to Swift types.

### PySerialize (Swift → Python)

```swift
public protocol PySerialize {
    func pyPointer() -> PyPointer
}
```

This protocol handles converting Swift objects to Python objects.

!!! info "Automatic Conformance"
    Classes marked with `@PyClass` automatically conform to `PyDeserialize`, enabling seamless conversion from Python to Swift. This means you can pass instances of your Python classes to Swift methods, and PySwiftKit will handle the conversion automatically.

## Custom Class Examples

Let's define two classes that we'll use throughout the examples:

```swift title="CustomClasses.swift"
import PySwiftKit
import PySerializing
import PySwiftObject
import PySwiftWrapper

@PyClass
class Person {
    
    @PyProperty
    var name: String
    
    @PyProperty
    var age: Int
    
    @PyInit
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    @PyMethod
    func greet() -> String {
        return "Hello, I'm \(name) and I'm \(age) years old"
    }
    
    @PyMethod
    func meet(other: Person) -> String {
        return "\(name) meets \(other.name)"
    }
}

@PyClass
class Book {
    
    @PyProperty
    var title: String
    
    @PyProperty
    var author: String
    
    @PyProperty
    var pages: Int
    
    @PyInit
    init(title: String, author: String, pages: Int) {
        self.title = title
        self.author = author
        self.pages = pages
    }
    
    @PyMethod
    func description() -> String {
        return "'\(title)' by \(author) (\(pages) pages)"
    }
    
    @PyMethod
    func compare_length(other: Book) -> String {
        if pages > other.pages {
            return "\(title) is longer than \(other.title)"
        } else if pages < other.pages {
            return "\(title) is shorter than \(other.title)"
        } else {
            return "\(title) and \(other.title) have the same length"
        }
    }
}

@PyModule
struct custom_types: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        Person.self,
        Book.self
    ]
}
```

## Using Custom Classes

### Basic Usage

```py title="basic_usage.py"
from custom_types import Person, Book

# Create instances
alice = Person(name="Alice", age=30)
bob = Person(name="Bob", age=25)

print(alice.greet())  # "Hello, I'm Alice and I'm 30 years old"
print(alice.meet(bob))  # "Alice meets Bob"

# Create books
book1 = Book(title="The Swift Guide", author="John Doe", pages=450)
book2 = Book(title="Python Basics", author="Jane Smith", pages=320)

print(book1.description())  # "'The Swift Guide' by John Doe (450 pages)"
print(book1.compare_length(book2))  # "The Swift Guide is longer than Python Basics"
```

## Arrays of Custom Classes

PySwiftKit automatically supports `Array<T>` where `T` conforms to `PyDeserialize`. This means you can pass lists of your custom classes between Python and Swift.

### Swift Implementation with Arrays

```swift title="LibraryManager.swift"
import PySwiftKit
import PySerializing
import PySwiftObject
import PySwiftWrapper

@PyClass
class LibraryManager {
    
    @PyProperty
    var books: [Book]
    
    @PyInit
    init(books: [Book]) {
        self.books = books
    }
    
    @PyMethod
    func add_book(book: Book) {
        books.append(book)
    }
    
    @PyMethod
    func total_pages() -> Int {
        return books.reduce(0) { $0 + $1.pages }
    }
    
    @PyMethod
    func get_books() -> [Book] {
        return books
    }
    
    @PyMethod
    func books_by_author(author: String) -> [Book] {
        return books.filter { $0.author == author }
    }
    
    @PyMethod
    func longest_book() -> Book? {
        return books.max(by: { $0.pages < $1.pages })
    }
}

@PyClass
class TeamManager {
    
    @PyProperty
    var members: [Person]
    
    @PyInit
    init(members: [Person]) {
        self.members = members
    }
    
    @PyMethod
    func add_member(person: Person) {
        members.append(person)
    }
    
    @PyMethod
    func get_members() -> [Person] {
        return members
    }
    
    @PyMethod
    func average_age() -> Double {
        guard !members.isEmpty else { return 0 }
        let total = members.reduce(0) { $0 + $1.age }
        return Double(total) / Double(members.count)
    }
    
    @PyMethod
    func find_by_name(name: String) -> Person? {
        return members.first { $0.name == name }
    }
    
    @PyMethod
    func introduce_all() -> [String] {
        return members.map { $0.greet() }
    }
}

@PyModule
struct library_module: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        Person.self,
        Book.self,
        LibraryManager.self,
        TeamManager.self
    ]
}
```

### Python Usage with Arrays

```py title="array_examples.py"
from library_module import Person, Book, LibraryManager, TeamManager

# Create a library with books
books = [
    Book(title="Swift Programming", author="Apple", pages=500),
    Book(title="Python Guide", author="Python Foundation", pages=400),
    Book(title="iOS Development", author="Apple", pages=600),
]

library = LibraryManager(books=books)

# Add more books
library.add_book(Book(title="Advanced Swift", author="Apple", pages=450))

# Get total pages
print(f"Total pages: {library.total_pages()}")  # Total pages: 1950

# Get all books
all_books = library.get_books()
for book in all_books:
    print(book.description())

# Filter books by author
apple_books = library.books_by_author("Apple")
print(f"Books by Apple: {len(apple_books)}")

# Find longest book
longest = library.longest_book()
if longest:
    print(f"Longest book: {longest.title} ({longest.pages} pages)")

# Working with team members
team = TeamManager(members=[
    Person(name="Alice", age=30),
    Person(name="Bob", age=25),
    Person(name="Charlie", age=35),
])

team.add_member(Person(name="Diana", age=28))

print(f"Average age: {team.average_age():.1f}")  # Average age: 29.5

# Get all introductions
intros = team.introduce_all()
for intro in intros:
    print(intro)

# Find specific person
alice = team.find_by_name("Alice")
if alice:
    print(f"Found: {alice.name}, age {alice.age}")
```

## Dictionaries with Custom Classes

PySwiftKit supports `Dictionary<String, T>` where `T` conforms to `PyDeserialize`. This enables using custom classes as dictionary values.

### Swift Implementation with Dictionaries

```swift title="DatabaseManager.swift"
import PySwiftKit
import PySerializing
import PySwiftObject
import PySwiftWrapper

@PyClass
class ContactBook {
    
    @PyProperty
    var contacts: [String: Person]
    
    @PyInit
    init(contacts: [String: Person]) {
        self.contacts = contacts
    }
    
    @PyMethod
    func add_contact(id: String, person: Person) {
        contacts[id] = person
    }
    
    @PyMethod
    func get_contact(id: String) -> Person? {
        return contacts[id]
    }
    
    @PyMethod
    func get_all_contacts() -> [String: Person] {
        return contacts
    }
    
    @PyMethod
    func remove_contact(id: String) -> Bool {
        if contacts[id] != nil {
            contacts.removeValue(forKey: id)
            return true
        }
        return false
    }
    
    @PyMethod
    func contact_count() -> Int {
        return contacts.count
    }
    
    @PyMethod
    func get_names() -> [String] {
        return contacts.values.map { $0.name }
    }
}

@PyClass
class BookCatalog {
    
    @PyProperty
    var catalog: [String: Book]
    
    @PyInit
    init(catalog: [String: Book]) {
        self.catalog = catalog
    }
    
    @PyMethod
    func add_book(isbn: String, book: Book) {
        catalog[isbn] = book
    }
    
    @PyMethod
    func get_book(isbn: String) -> Book? {
        return catalog[isbn]
    }
    
    @PyMethod
    func get_catalog() -> [String: Book] {
        return catalog
    }
    
    @PyMethod
    func search_by_title(title: String) -> [(String, Book)] {
        return catalog.filter { $0.value.title.contains(title) }
            .map { ($0.key, $0.value) }
    }
    
    @PyMethod
    func total_books() -> Int {
        return catalog.count
    }
    
    @PyMethod
    func all_authors() -> [String] {
        return Array(Set(catalog.values.map { $0.author }))
    }
}

@PyModule
struct database_module: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        Person.self,
        Book.self,
        ContactBook.self,
        BookCatalog.self
    ]
}
```

### Python Usage with Dictionaries

```py title="dictionary_examples.py"
from database_module import Person, Book, ContactBook, BookCatalog

# Create contact book with dictionary
contacts = {
    "alice_001": Person(name="Alice Johnson", age=30),
    "bob_002": Person(name="Bob Smith", age=25),
    "charlie_003": Person(name="Charlie Brown", age=35),
}

contact_book = ContactBook(contacts=contacts)

# Add new contact
contact_book.add_contact("diana_004", Person(name="Diana Prince", age=28))

# Get specific contact
alice = contact_book.get_contact("alice_001")
if alice:
    print(alice.greet())

# Get all contacts
all_contacts = contact_book.get_all_contacts()
for contact_id, person in all_contacts.items():
    print(f"{contact_id}: {person.name}")

# Get just names
names = contact_book.get_names()
print(f"Contact names: {', '.join(names)}")

# Remove a contact
if contact_book.remove_contact("bob_002"):
    print("Bob removed from contacts")

print(f"Total contacts: {contact_book.contact_count()}")

# Working with book catalog
catalog = {
    "978-0-123456-78-9": Book(title="Swift Programming", author="Apple", pages=500),
    "978-0-987654-32-1": Book(title="Python Guide", author="Guido", pages=400),
    "978-0-111111-11-1": Book(title="iOS Development", author="Apple", pages=600),
}

book_catalog = BookCatalog(catalog=catalog)

# Add new book
book_catalog.add_book(
    "978-0-222222-22-2",
    Book(title="Advanced Swift", author="Apple", pages=450)
)

# Get specific book
book = book_catalog.get_book("978-0-123456-78-9")
if book:
    print(book.description())

# Search by title
swift_books = book_catalog.search_by_title("Swift")
print(f"Found {len(swift_books)} books with 'Swift' in title:")
for isbn, book in swift_books:
    print(f"  {isbn}: {book.title}")

# Get unique authors
authors = book_catalog.all_authors()
print(f"Authors in catalog: {', '.join(authors)}")

print(f"Total books: {book_catalog.total_books()}")
```

## Advanced Example: Nested Collections

You can combine arrays and dictionaries for more complex data structures:

```swift title="AdvancedCollections.swift"
import PySwiftKit
import PySerializing
import PySwiftObject
import PySwiftWrapper

@PyClass
class University {
    
    @PyProperty
    var departments: [String: [Person]]
    
    @PyInit
    init(departments: [String: [Person]]) {
        self.departments = departments
    }
    
    @PyMethod
    func add_department(name: String, staff: [Person]) {
        departments[name] = staff
    }
    
    @PyMethod
    func add_to_department(dept: String, person: Person) {
        if departments[dept] != nil {
            departments[dept]?.append(person)
        } else {
            departments[dept] = [person]
        }
    }
    
    @PyMethod
    func get_department(name: String) -> [Person]? {
        return departments[name]
    }
    
    @PyMethod
    func total_staff() -> Int {
        return departments.values.reduce(0) { $0 + $1.count }
    }
    
    @PyMethod
    func department_sizes() -> [String: Int] {
        return departments.mapValues { $0.count }
    }
    
    @PyMethod
    func find_person(name: String) -> (String, Person)? {
        for (dept, people) in departments {
            if let person = people.first(where: { $0.name == name }) {
                return (dept, person)
            }
        }
        return nil
    }
}

@PyClass
class Library {
    
    @PyProperty
    var sections: [String: [Book]]
    
    @PyInit
    init(sections: [String: [Book]]) {
        self.sections = sections
    }
    
    @PyMethod
    func add_section(name: String, books: [Book]) {
        sections[name] = books
    }
    
    @PyMethod
    func add_to_section(section: String, book: Book) {
        if sections[section] != nil {
            sections[section]?.append(book)
        } else {
            sections[section] = [book]
        }
    }
    
    @PyMethod
    func get_section(name: String) -> [Book]? {
        return sections[name]
    }
    
    @PyMethod
    func total_books() -> Int {
        return sections.values.reduce(0) { $0 + $1.count }
    }
    
    @PyMethod
    func section_statistics() -> [String: (Int, Int)] {
        return sections.mapValues { books in
            let count = books.count
            let totalPages = books.reduce(0) { $0 + $1.pages }
            return (count, totalPages)
        }
    }
}

@PyModule
struct advanced_module: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        Person.self,
        Book.self,
        University.self,
        Library.self
    ]
}
```

### Python Usage with Nested Collections

```py title="nested_examples.py"
from advanced_module import Person, Book, University, Library

# Create university with departments
university = University(departments={
    "Computer Science": [
        Person(name="Dr. Smith", age=45),
        Person(name="Dr. Johnson", age=38),
    ],
    "Mathematics": [
        Person(name="Prof. Brown", age=52),
        Person(name="Dr. Davis", age=41),
    ],
})

# Add new department
university.add_department("Physics", [
    Person(name="Dr. Wilson", age=39),
])

# Add person to existing department
university.add_to_department("Computer Science", Person(name="Dr. Taylor", age=33))

# Get department staff
cs_staff = university.get_department("Computer Science")
if cs_staff:
    print(f"Computer Science has {len(cs_staff)} staff members:")
    for person in cs_staff:
        print(f"  - {person.name}, {person.age}")

# Get total staff count
print(f"Total university staff: {university.total_staff()}")

# Get department sizes
sizes = university.department_sizes()
for dept, size in sizes.items():
    print(f"{dept}: {size} staff")

# Find a specific person
result = university.find_person("Dr. Smith")
if result:
    dept, person = result
    print(f"Found {person.name} in {dept} department")

# Library with sections
library = Library(sections={
    "Science Fiction": [
        Book(title="Dune", author="Frank Herbert", pages=688),
        Book(title="Foundation", author="Isaac Asimov", pages=255),
    ],
    "Technical": [
        Book(title="Swift Programming", author="Apple", pages=500),
        Book(title="Python Guide", author="Guido", pages=400),
    ],
})

# Add new section
library.add_section("Mystery", [
    Book(title="Murder on the Orient Express", author="Agatha Christie", pages=256),
])

# Add book to section
library.add_to_section("Technical", Book(title="iOS Development", author="Apple", pages=600))

# Get section books
sci_fi = library.get_section("Science Fiction")
if sci_fi:
    print("\nScience Fiction books:")
    for book in sci_fi:
        print(f"  - {book.description()}")

# Get statistics
stats = library.section_statistics()
for section, (count, pages) in stats.items():
    print(f"{section}: {count} books, {pages} total pages")

print(f"\nTotal books in library: {library.total_books()}")
```

## Type Conversion Summary

!!! info "Automatic Conversions"
    When you mark a class with `@PyClass`:
    
    - ✓ Single instance: `Person` ↔ Python object
    - ✓ Arrays: `[Person]` ↔ `list[Person]`
    - ✓ Dictionaries: `[String: Person]` ↔ `dict[str, Person]`
    - ✓ Nested collections: `[String: [Person]]` ↔ `dict[str, list[Person]]`
    - ✓ Optional types: `Person?` ↔ `Person | None`
    - ✓ Arrays of optionals: `[Person?]` ↔ `list[Person | None]`

!!! tip "Best Practices"
    1. **Use `@PyProperty`** for properties you want accessible from Python
    2. **Use `@PyMethod`** for methods you want to call from Python
    3. **Collections are copied**, not referenced - changes in Python don't affect Swift arrays
    4. **Always return collections** when you want Python to access modified data
    5. **Use optionals** (`Person?`) when a value might not exist

!!! warning "Performance Considerations"
    - Passing individual objects is fast
    - Large arrays/dictionaries involve copying data between Python and Swift
    - For very large datasets, consider passing indices or using iterators
    - Nested collections (e.g., `[String: [Person]]`) involve multiple copies

## Error Handling

When type conversion fails, PySwiftKit throws an error:

```swift title="ErrorHandling.swift"
@PyClass
class SafeProcessor {
    
    @PyMethod
    func process_people(people: [Person]) -> String {
        guard !people.isEmpty else {
            return "No people to process"
        }
        return "Processed \(people.count) people"
    }
    
    @PyMethod
    func safe_get_book(from catalog: [String: Book], isbn: String) -> Book? {
        return catalog[isbn]
    }
}
```

```py title="error_handling.py"
from advanced_module import SafeProcessor, Person, Book

processor = SafeProcessor()

# Empty list is fine
result = processor.process_people([])
print(result)  # "No people to process"

# Valid list
people = [Person(name="Alice", age=30)]
result = processor.process_people(people)
print(result)  # "Processed 1 people"

# Safe dictionary access
catalog = {
    "123": Book(title="Swift Guide", author="Apple", pages=500),
}
book = processor.safe_get_book(catalog, "123")
if book:
    print(book.title)

# Missing key returns None
book = processor.safe_get_book(catalog, "999")
if book is None:
    print("Book not found")
```

## Complete Working Example

Here's a complete example demonstrating all concepts together:

```swift title="CompleteExample.swift"
import PySwiftKit
import PySerializing
import PySwiftObject
import PySwiftWrapper

@PyClass
class Student {
    @PyProperty
    var name: String
    
    @PyProperty
    var grade: Int
    
    @PyInit
    init(name: String, grade: Int) {
        self.name = name
        self.grade = grade
    }
    
    @PyMethod
    func status() -> String {
        return "\(name): Grade \(grade)"
    }
}

@PyClass
class School {
    @PyProperty
    var classes: [String: [Student]]
    
    @PyInit
    init(classes: [String: [Student]]) {
        self.classes = classes
    }
    
    @PyMethod
    func enroll(className: String, student: Student) {
        if classes[className] != nil {
            classes[className]?.append(student)
        } else {
            classes[className] = [student]
        }
    }
    
    @PyMethod
    func get_class(name: String) -> [Student]? {
        return classes[name]
    }
    
    @PyMethod
    func all_classes() -> [String: [Student]] {
        return classes
    }
    
    @PyMethod
    func total_students() -> Int {
        return classes.values.reduce(0) { $0 + $1.count }
    }
    
    @PyMethod
    func class_averages() -> [String: Double] {
        return classes.mapValues { students in
            guard !students.isEmpty else { return 0.0 }
            let total = students.reduce(0) { $0 + $1.grade }
            return Double(total) / Double(students.count)
        }
    }
}

@PyModule
struct school_module: PyModuleProtocol {
    static var py_classes: [any (PyClassProtocol & AnyObject).Type] = [
        Student.self,
        School.self
    ]
}
```

```py title="complete_example.py"
from school_module import Student, School

# Create school with initial classes
school = School(classes={
    "Math": [
        Student(name="Alice", grade=95),
        Student(name="Bob", grade=87),
    ],
    "Science": [
        Student(name="Charlie", grade=92),
        Student(name="Diana", grade=88),
    ],
})

# Enroll new students
school.enroll("Math", Student(name="Eve", grade=91))
school.enroll("History", Student(name="Frank", grade=85))

# Get specific class
math_class = school.get_class("Math")
if math_class:
    print("Math class students:")
    for student in math_class:
        print(f"  {student.status()}")

# Get all classes
all_classes = school.all_classes()
print(f"\nTotal classes: {len(all_classes)}")
print(f"Total students: {school.total_students()}")

# Get class averages
averages = school.class_averages()
print("\nClass averages:")
for class_name, avg in averages.items():
    print(f"  {class_name}: {avg:.1f}")
```

This expanded type support enables you to build complex data structures and pass them seamlessly between Python and Swift!
