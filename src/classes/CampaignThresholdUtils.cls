public with sharing class CampaignThresholdUtils {

	public static final String RESOLVER_CLASS_SUFFIX = 'Resolver';

	public interface IResolver {
		Boolean isThresholdMet(CampaignMembershipUtils.ResolverData resolverData);
	}

	public class BirthdayResolver implements IResolver {

		public Boolean isThresholdMet(CampaignMembershipUtils.ResolverData resolverData) {
			if (resolverData.shouldAdvertise) {
				return resolverData.customer.Birthdate != null && 
					Integer.valueOf(resolverData.customer.Birthdate.month()) == System.today().month() + 1;
			} else {
				return resolverData.customer.Birthdate != null && 
					Integer.valueOf(resolverData.customer.Birthdate.month()) == System.today().month();
			}
		}

	}

	public class EmployeeResolver implements IResolver {

		public Boolean isThresholdMet(CampaignMembershipUtils.ResolverData resolverData) {
			return resolverData.customer.IsEmployee__c;
		}

	}

	public class WeekendResolver implements IResolver {

		@TestVisible
		private Set<String> weekdays = new Set<String>{'Mon','Tue','Wed','Thu','Fri'};
		
		@TestVisible
		private Set<String> weekend = new Set<String>{'Sat','Sun'};

		public Boolean isThresholdMet(CampaignMembershipUtils.ResolverData resolverData) {
			if (resolverData.shouldAdvertise) {
				return weekdays.contains(System.now().format('E'));
			} else {
				return weekend.contains(System.now().format('E'));
			}
		}

	}
	
}