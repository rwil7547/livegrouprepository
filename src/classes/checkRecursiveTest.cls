@isTest
private class checkRecursiveTest {
	
	@isTest static void checkRecursiveClassTest() {

		System.assertEquals(true, checkRecursive.beforeInsert());
		System.assertEquals(false, checkRecursive.beforeInsert());
		System.assertEquals(true, checkRecursive.beforeUpdate());
		System.assertEquals(false, checkRecursive.beforeUpdate());
		System.assertEquals(true, checkRecursive.beforeDelete());
		System.assertEquals(false, checkRecursive.beforeDelete());
		System.assertEquals(true, checkRecursive.afterInsert());
		System.assertEquals(false, checkRecursive.afterInsert());
		System.assertEquals(true, checkRecursive.afterUpdate());
		System.assertEquals(false, checkRecursive.afterUpdate());
		System.assertEquals(true, checkRecursive.afterDelete());
		System.assertEquals(false, checkRecursive.afterDelete());
		System.assertEquals(true, checkRecursive.afterUndelete());
		System.assertEquals(false, checkRecursive.afterUndelete());

		checkRecursive.resetAll();

		System.assertEquals(true, checkRecursive.beforeInsert());
		System.assertEquals(false, checkRecursive.beforeInsert());
		System.assertEquals(true, checkRecursive.beforeUpdate());
		System.assertEquals(false, checkRecursive.beforeUpdate());
		System.assertEquals(true, checkRecursive.beforeDelete());
		System.assertEquals(false, checkRecursive.beforeDelete());
		System.assertEquals(true, checkRecursive.afterInsert());
		System.assertEquals(false, checkRecursive.afterInsert());
		System.assertEquals(true, checkRecursive.afterUpdate());
		System.assertEquals(false, checkRecursive.afterUpdate());
		System.assertEquals(true, checkRecursive.afterDelete());
		System.assertEquals(false, checkRecursive.afterDelete());
		System.assertEquals(true, checkRecursive.afterUndelete());
		System.assertEquals(false, checkRecursive.afterUndelete());


	}		

	
}