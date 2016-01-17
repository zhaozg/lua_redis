require "lunit"

module( "my_testcase", lunit.testcase, package.seeall )

local redis = require "lua_redis"
local instance = redis.connect("test", {["ip"] = "127.0.0.1"})

function test_string_commands()
  local rep
  assert_error(function() return instance.abcd("aaa") end)
  rep = instance.set("testkey", "t")
  assert_true(rep == "OK")
  rep = instance.append("testkey", "est")
  assert_true(type(rep) == "number")
  rep = instance.get("testkey")
  assert_true(rep == "test")
  rep = instance.bitcount("testkey")
  assert_true(rep == 17)
  instance.set("testkey2", "tes")
  rep = instance.bitop("XOR", "testkey", "testkey2")
  assert_true(rep == 3)
  instance.set("testkey", 20)
  instance.decr("testkey")
  rep = instance.get("testkey")
  assert_true(rep == "19")
  instance.decrby("testkey", 3)
  rep = instance.get("testkey")
  assert_true(rep == "16")
  rep = instance.incr("testkey")
  assert_true(rep == 17)
  rep = instance.incrby("testkey", 3)
  assert_true(rep == 20)
  rep = instance.incrbyfloat("testkey", 0.5)
  assert_true(rep == '20.5')
  rep = instance.getbit("testkey", 10)
  assert_true(rep == 1)
  instance.set("testkey","Supercalifragilisticexpialidocious")
  rep = instance.getrange("testkey", 0, 4)
  assert_true(rep == "Super")
  rep = instance.getset("testkey", "test")
  assert_true(rep == "Supercalifragilisticexpialidocious")
  rep = instance.mget("testkey", "testkey2")
  assert_true(type(rep) == "table" and rep[1] == "test" and rep[2] == "tes")
  instance.mset("testkey", "tes", "testkey2", "test")
  rep = instance.mget("testkey", "testkey2")
  assert_true(type(rep) == "table" and rep[2] == "test" and rep[1] == "tes")
  instance.msetnx("testkey", "test", "testkey2", "tes", "testkey3", "est")
  rep = instance.mget("testkey", "testkey2", "testkey3")
  assert_true(type(rep) == "table" and rep[2] == "test" and rep[1] == "tes")
  instance.msetnx("testkey3", "test", "testkey4", "rest")
  rep = instance.mget("testkey3", "testkey4")
  assert_true(type(rep) == "table" and rep[1] == "test" and rep[2] == "rest")
  instance.psetex("foo", 2000, "bar")
  rep = instance.get("foo")
  assert_true(rep == "bar")
  os.execute("sleep 2")
  rep = instance.get("foo")
  assert_nil(rep)
  instance.del("foo")
  instance.setbit("foo", 4, 1)
  rep = instance.get("foo")
  assert_true(rep == "\b")
  instance.setex("foo", 2, "bar")
  rep = instance.get("foo")
  assert_true(rep == "bar")
  os.execute("sleep 2")
  rep = instance.get("foo")
  assert_nil(rep)
  instance.set("foo", "bar")
  instance.setnx("foo", "barz")
  rep = instance.get("foo")
  assert_false(rep == "barz")
  instance.setrange("foo", 2, "rz")
  rep = instance.get("foo")
  assert_true(rep == "barz")
  rep = instance.strlen("foo")
  assert_true(rep == 4)
end
  
function test_list_commands()
  local rep
  instance.rpush("mylist", "a", "b", "c")
  rep = instance.llen("mylist") 
  assert_true(rep == 3)
  instance.linsert("mylist", "BEFORE", "c", "d")
  rep = instance.lindex("mylist", 2)
  assert_true(rep == "d")
  rep = instance.lpop("mylist")
  assert_true(rep == "a")
  rep = instance.lrange("mylist", 0, -1)
  assert_true(type(rep) == "table")
  assert_true(#rep == 3)
  instance.lpush("mylist", "z")
  rep = instance.lindex("mylist", 0)
  assert_true(rep == "z")
  instance.del("mylist")
end

function test_set_commands()
  local rep
  instance.sadd("myset", "a", "b", "c")
  rep = instance.scard("myset")
  assert_true(rep == 3)
  instance.sadd("myset2", "b", "c", "d")
  rep = instance.sdiff("myset", "myset2")
  assert_true(type(rep) == "table")
  assert_true(#rep == 1 and rep[1] == "a")
  instance.sdiffstore("myset3", "myset2", "myset")
  rep = instance.smembers("myset3")
  assert_true(type(rep) == "table" and #rep == 1 and rep[1] == "d")
  rep = instance.sunion("myset", "myset2", "myset3")
  assert_true(type(rep) == "table" and #rep == 4)
end

function test_hash_commands()
  
end