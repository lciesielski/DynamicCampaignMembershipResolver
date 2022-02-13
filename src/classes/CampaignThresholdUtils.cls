public with sharing class CampaignThresholdUtils {

	public static final String RESOLVER_CLASS_SUFFIX = 'Resolver';

	public interface IResolver {
		Boolean isThresholdMet(ResolverData resolverData);
	}

	public class BirthdayResolver implements IResolver {

		public Boolean isThresholdMet(ResolverData resolverData) {
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

		public Boolean isThresholdMet(ResolverData resolverData) {
			return resolverData.customer.IsEmployee__c;
		}

	}

	public class WeekendResolver implements IResolver {

		@TestVisible
		private Set<String> weekdays = new Set<String>{'Mon','Tue','Wed','Thu','Fri'};
		
		@TestVisible
		private Set<String> weekend = new Set<String>{'Sat','Sun'};

		public Boolean isThresholdMet(ResolverData resolverData) {
			if (resolverData.shouldAdvertise) {
				return weekdays.contains(System.now().format('E'));
			} else {
				return weekend.contains(System.now().format('E'));
			}
		}

	}

	public class ResolverData {
		public Boolean shouldAdvertise = false;
		public Campaign campaign;
		public CampaignThreshold__c threshold;
		public Contact customer;
	}
	
}