module netorcai_test_json
    use netorcai_json
    use netorcai_utils
    use zofu

    implicit none
    public
contains
    subroutine setup()
        ! Nothing to do
    end subroutine setup

    subroutine test_tostring(test)
        class(unit_test_type), intent(inout) :: test
        class(JsonValue), pointer :: jsonVal
        class(JsonArray), pointer :: jsonArr
        class(JsonObject), pointer :: jsonObj
        character(len=:), allocatable :: jsonStr

        ! Null
        jsonVal => json_makeNull()
        call test%assert(utils_toLower(jsonVal%toString()), "null")
        call jsonVal%destroy()

        ! Logical (true)
        jsonVal => json_makeBool(.true.)
        call test%assert(utils_toLower(jsonVal%toString()), "true")
        call jsonVal%destroy()

        ! Logical (false)
        jsonVal => json_makeBool(.false.)
        call test%assert(utils_toLower(jsonVal%toString()), "false")
        call jsonVal%destroy()

        ! Positive integers (int)
        jsonVal => json_makeInt(42_4)
        call test%assert(jsonVal%toString(), "42")
        call jsonVal%destroy()

        ! Positive integers (long)
        jsonVal => json_makeLong(420000000000_8)
        call test%assert(jsonVal%toString(), "420000000000")
        call jsonVal%destroy()

        ! Negative integers (int)
        jsonVal => json_makeInt(-42_4)
        call test%assert(jsonVal%toString(), "-42")
        call jsonVal%destroy()

        ! Negative integers (long)
        jsonVal => json_makeLong(-420000000000_8)
        call test%assert(jsonVal%toString(), "-420000000000")
        call jsonVal%destroy()

        ! Positive reals (float)
        jsonVal => json_makeFloat(3.1415926535_4)
        jsonStr = jsonVal%toString()
        call test%assert(jsonStr(1:6), "3.1415")
        call jsonVal%destroy()

        ! Negative reals (float)
        jsonVal => json_makeFloat(-3.1415926535_4)
        jsonStr = jsonVal%toString()
        call test%assert(jsonStr(1:7), "-3.1415")
        call jsonVal%destroy()

        ! Positive reals (double)
        jsonVal => json_makeDouble(3.1415926535_8)
        jsonStr = jsonVal%toString()
        call test%assert(jsonStr(1:12), "3.1415926535")
        call jsonVal%destroy()

        ! Negative reals (double)
        jsonVal => json_makeDouble(-3.1415926535_8)
        jsonStr = jsonVal%toString()
        call test%assert(jsonStr(1:13), "-3.1415926535")
        call jsonVal%destroy()

        ! Strings
        jsonVal => json_makeString('test')
        call test%assert(jsonVal%toString(), '"test"')
        call jsonVal%destroy()

        ! Empty arrays
        jsonVal => json_makeArray()
        jsonStr = utils_strReplace(jsonVal%toString(), " ", "")
        call test%assert(jsonStr, '[]')
        call jsonVal%destroy()

        ! Arrays
        jsonArr => json_makeArray()
        call jsonArr%add(json_makeInt(42_4))
        call jsonArr%add(json_makeInt(0_4))
        jsonVal => jsonArr
        jsonStr = utils_strReplace(jsonVal%toString(), " ", "")
        call test%assert(jsonStr, '[42,0]')
        call jsonVal%destroy()

        ! Empty objects
        jsonVal => json_makeObject()
        jsonStr = utils_strReplace(jsonVal%toString(), " ", "")
        call test%assert(jsonStr, '{}')
        call jsonVal%destroy()

        ! Objects
        jsonObj => json_makeObject()
        call jsonObj%add("bouh", json_makeInt(42_4))
        call jsonObj%add("bwa", json_makeInt(0_4))
        jsonVal => jsonObj
        jsonStr = utils_strReplace(jsonVal%toString(), " ", "")
        call test%assert(jsonStr, '{"bouh":42,"bwa":0}')
        call jsonVal%destroy()
    end subroutine test_tostring

    subroutine test_string_escape(test)
        class(unit_test_type), intent(inout) :: test
        type(JsonDocument), allocatable :: doc
        class(Jsonvalue), pointer :: jsonValue
        character(len=:), allocatable :: inJsonStr, outJsonStr
        logical :: fail

        inJsonStr = '{"NameWith\"Inside":"ValueWith\"Inside"}'
        doc = json_parse(inJsonStr, fail)
        call test%assert(.not. fail)
        jsonValue => doc%getRoot()
        call jsonValue%lookup('NameWith"Inside', outJsonStr, fail)
        call test%assert(.not. fail)
        call test%assert(outJsonStr, 'ValueWith"Inside')
        outJsonStr = doc%toString()
        call test%assert(utils_strReplace(outJsonStr, " ", ""), inJsonStr)
    end subroutine test_string_escape

    subroutine test_parse(test)
        class(unit_test_type), intent(inout) :: test
        type(JsonDocument), allocatable :: doc
        logical :: fail

        doc = json_parse('42', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('-42', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('3.141592')
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('""', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('"\""', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('"test"', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('null', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('true', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('false', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('{}', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('{"value": 42}', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('[]', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('[1]', fail)
        call test%assert(.not. fail)
        deallocate(doc)

        doc = json_parse('[1, 2]', fail)
        call test%assert(.not. fail)
        deallocate(doc)
    end subroutine test_parse

    ! TODO: test get & lookup

    subroutine test_perf(test)
        class(unit_test_type), intent(inout) :: test
        type(JsonItem), dimension(:), allocatable :: arr
        type(JsonDocument), allocatable :: doc
        class(JsonValue), pointer :: root
        character(len=:), allocatable :: jsonStrBase
        character(len=:), allocatable :: jsonStr
        logical :: fail
        integer :: i, cur, elemCount

        elemCount = 64000
        allocate(character(elemCount*10) :: jsonStrBase)

        ! Build the string: a 50 Ko json document
        jsonStrBase(1:2) = '[0'
        cur = 3
        do i = 1, elemCount
            jsonStrBase(cur:cur) = ','
            jsonStr = utils_intToStr(i)
            jsonStrBase(cur+1:cur+len(jsonStr)) = jsonStr
            deallocate(jsonStr)
            cur = cur + len(jsonStr) + 1
        end do
        jsonStrBase(cur:cur+1) = '] '
        jsonStr = jsonStrBase(1:cur+1)

        ! Parse the document once.
        ! Remember that FORTRAN deallocates allocatable variables only at
        ! the end of the function, except if you use a FORTRAN 2008 block.
        ! Note also that ALL values related to the document are deallocated
        ! when the document is deallocated, unless they are cloned.
        doc = json_parse(jsonStr, fail)
        call test%assert(.not. fail)
        root => doc%getRoot()
        call root%get(arr, fail)
        call test%assert(.not. fail)
        call test%assert(size(arr), elemCount+1)
        call arr(1)%value%get(i, fail)
        call test%assert(.not. fail)
        call test%assert(i, 0)
        call arr(2)%value%get(i, fail)
        call test%assert(.not. fail)
        call test%assert(i, 1)
        root => arr(size(arr))%value
        call root%get(i, fail)
        call test%assert(.not. fail)
        call test%assert(i, elemCount)
        deallocate(arr)
        deallocate(doc)

        ! ~10 Mo/s on my laptop
        do i = 2,10
            doc = json_parse(jsonStr, fail)
            call test%assert(.not. fail)
            deallocate(doc)
        end do
    end subroutine test_perf
end module netorcai_test_json

