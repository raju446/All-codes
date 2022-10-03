@isTest
public with sharing class CreatePOBoxControllerTest {
    private static PO_Box__c PoBox; 
	
	private static void init(){
		PoBox = new PO_Box__c();
		PoBox.PO_Box_Number__c = '123';
		insert PoBox;
	}
	
	public static testmethod void TestCreatePOBoxController(){
		init();
		ApexPages.StandardController sc = new ApexPages.StandardController(PoBox);
		CreatePOBoxController cpb = new CreatePOBoxController(sc);
		cpb.endPOBoxNum = '34';
		//cpb.startPOBoxNum = '26';
		cpb.savePOBoxes();
		cpb.cancelPOBox();
	}
	public static testmethod void TestCreatePOBoxController2(){
		init();
		ApexPages.StandardController sc = new ApexPages.StandardController(PoBox);
		CreatePOBoxController cpb = new CreatePOBoxController(sc);
		cpb.endPOBoxNum = '134';
		cpb.startPOBoxNum = '126';
		cpb.savePOBoxes();
		cpb.cancelPOBox();
	}
	public static testmethod void TestCreatePOBoxController3(){
		init();
		ApexPages.StandardController sc = new ApexPages.StandardController(PoBox);
		CreatePOBoxController cpb = new CreatePOBoxController(sc);
		cpb.endPOBoxNum = '100';
		cpb.startPOBoxNum = '110';
		cpb.savePOBoxes();
		cpb.cancelPOBox();
	}
}