describe 'ColUtils:ADD', =>
  obj = {}

  beforeEach ->
    obj = {}

  it 'test Add to empty', =>
    colUtils.add(1).as("foo").to("foos").on(obj).ifAbsent()
    expect(obj.foos.foo).toEqual(1)

  it 'test add when add object twice ', =>
    val = { count: 1 }

    colUtils.add(val).as("foo").to("foos").on(obj).ifAbsent()
    obj.foos.foo.count += 1
    expect(obj.foos.foo.count).toEqual(2)

    val1 = { count: 1 }

    colUtils.add(val1).as("foo").to("foos").on(obj).ifAbsent()
    expect(obj.foos.foo.count).toEqual(2)
    expect(obj.foos.foo).toEqual(val)

  it 'test add when collection and object already there', =>
    val = count: 3

    obj.foos =
        foo: val

    colUtils.add(val).as("foo").to("foos").on(obj).ifAbsent()
    obj.foos.foo.count += 1
    expect(obj.foos.foo.count).toEqual(4)

    val1 = { count: 111 }

    colUtils.add(val1).as("foo").to("foos").on(obj).ifAbsent()
    expect(obj.foos.foo.count).toEqual(4)
    expect(obj.foos.foo).toEqual(val)

  it 'test add when collection and object already there but force', =>
    val = count: 3

    obj.foos =
        foo: val

    colUtils.add(val).as("foo").to("foos").on(obj).ifAbsent()
    obj.foos.foo.count += 1
    expect(obj.foos.foo.count).toEqual(4)

    val1 = { count: 111 }

    colUtils.add(val1).as("foo").to("foos").on(obj).now()
    expect(obj.foos.foo.count).toEqual(111)
    expect(obj.foos.foo).toEqual(val1)


describe 'ColUtils:Push', =>
  obj = {}

  beforeEach ->
    obj = {}

  it 'test Add to empty', =>
    colUtils.push(1).into("foos").on(obj).now()
    colUtils.push(2).into("foos").on(obj).now()
    colUtils.push(3).into("foos").on(obj).now()

    expect(obj.foos[0]).toEqual(1)
    expect(obj.foos[1]).toEqual(2)
    expect(obj.foos[2]).toEqual(3)

  it 'test push', =>
    colUtils.push(1).into("foos").on(obj).now()
    colUtils.push(3).into("foos").on(obj).now()

    expect(obj.foos[0]).toEqual(1)
    expect(obj.foos[1]).toEqual(3)

  it 'test unless', =>
    colUtils.push(1).into("foos").on(obj).now()
    colUtils.push(2).into("foos").on(obj).unless(true)
    colUtils.push(3).into("foos").on(obj).now()

    expect(obj.foos[0]).toEqual(1)
    expect(obj.foos[1]).toEqual(3)
