@isTest
private class CampaignMembershipUtilsTest {

	private static final String CAMPAIGN_NAME = 'Test Campaign';
	private static final String EMPLOYEE_CONTACT_BORN_MARCH_FIRST_NAME = 'Employee March';
	private static final String EMPLOYEE_CONTACT_BORN_TODAY_FIRST_NAME = 'Employee Today';
	private static final String STANDARD_CONTACT_BORN_TODAY_FIRST_NAME = 'Standard Today';
	
	@testSetup 
	private static void setup() {
		final Campaign campaign = new Campaign(
			Name = CAMPAIGN_NAME,
			Status = 'Active',
			IsActive = true
		);
		insert campaign;

		final Map<String, Schema.RecordTypeInfo> recordTypeInfo = 
			CampaignThreshold__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

		insert new List<CampaignThreshold__c>{
			new CampaignThreshold__c(
				RecordTypeId = recordTypeInfo.get('Employee').getRecordTypeId(),
				Campaign__c = campaign.Id,
				EquationPlace__c = 1
			),
			new CampaignThreshold__c(
				RecordTypeId = recordTypeInfo.get('Birthday').getRecordTypeId(),
				Campaign__c = campaign.Id,
				EquationPlace__c = 2
			),
			new CampaignThreshold__c(
				RecordTypeId = recordTypeInfo.get('Weekend').getRecordTypeId(),
				Campaign__c = campaign.Id,
				EquationPlace__c = 3
			)
		};

		campaign.Equation__c = '(1 AND (2 OR 3))';
		update campaign;

		insert new List<Contact>{
			new Contact(
				Birthdate = System.today(),
				FirstName = EMPLOYEE_CONTACT_BORN_TODAY_FIRST_NAME,
				LastName = 'Test Contact',
				IsEmployee__c = true
			),
			new Contact(
				Birthdate = System.today(),
				FirstName = STANDARD_CONTACT_BORN_TODAY_FIRST_NAME,
				LastName = 'Test Contact',
				IsEmployee__c = false
			),
			new Contact(
				Birthdate = Date.newInstance(2000, 3, 15),
				FirstName = EMPLOYEE_CONTACT_BORN_MARCH_FIRST_NAME,
				LastName = 'Test Contact',
				IsEmployee__c = true
			)
		};
	}

	@isTest 
	private static void itShouldResolveThresholds() {
		// Given
		final Map<String, Contact> contactsByFirstName = new Map<String, Contact>();
		final CampaignMembershipUtils CampaignMembershipUtils = new CampaignMembershipUtils();
		final CampaignThresholdUtils.WeekendResolver weekendResolver = new CampaignThresholdUtils.WeekendResolver();
		final String today =  System.now().format('E');

		final Campaign campaign = [
			SELECT Equation__c, 
				(SELECT EquationPlace__c, RecordType.DeveloperName FROM CampaignThresholds__r) 
			FROM Campaign 
			WHERE Name = :CAMPAIGN_NAME
		];

		for (Contact contact : [
			SELECT FirstName, Birthdate, IsEmployee__c 
			FROM Contact 
		]) {
			contactsByFirstName.put(contact.FirstName, contact);
		}

		// Then
		if (weekendResolver.weekend.contains(today) || System.today().month() == 3) {
			System.assert(CampaignMembershipUtils.isCustomerEligibleForCampaign(
				contactsByFirstName.get(EMPLOYEE_CONTACT_BORN_TODAY_FIRST_NAME), campaign)
			);

			System.assert(CampaignMembershipUtils.isCustomerEligibleForCampaign(
				contactsByFirstName.get(EMPLOYEE_CONTACT_BORN_MARCH_FIRST_NAME), campaign)
			);

			System.assert(!CampaignMembershipUtils.isCustomerEligibleForCampaign(
				contactsByFirstName.get(STANDARD_CONTACT_BORN_TODAY_FIRST_NAME), campaign)
			);
		} else {
			System.assert(CampaignMembershipUtils.isCustomerEligibleForCampaign(
				contactsByFirstName.get(EMPLOYEE_CONTACT_BORN_TODAY_FIRST_NAME), campaign)
			);
			
			System.assert(!CampaignMembershipUtils.isCustomerEligibleForCampaign(
				contactsByFirstName.get(EMPLOYEE_CONTACT_BORN_MARCH_FIRST_NAME), campaign)
			);

			System.assert(!CampaignMembershipUtils.isCustomerEligibleForCampaign(
				contactsByFirstName.get(STANDARD_CONTACT_BORN_TODAY_FIRST_NAME), campaign)
			);
		}
	}

}