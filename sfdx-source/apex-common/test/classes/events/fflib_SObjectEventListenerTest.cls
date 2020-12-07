/**
 * File Name: fflib_SObjectEventListenerTest 
 * Description: 
 *
 * @author: architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com 
 */
@IsTest
private class fflib_SObjectEventListenerTest
{
	private static final TriggerOperation BEFORE_INSERT = System.TriggerOperation.BEFORE_INSERT;
	private static final TriggerOperation BEFORE_UPDATE = System.TriggerOperation.BEFORE_UPDATE;
	private static final TriggerOperation BEFORE_DELETE = System.TriggerOperation.BEFORE_DELETE;
	private static final TriggerOperation AFTER_INSERT = System.TriggerOperation.AFTER_INSERT;
	private static final TriggerOperation AFTER_UPDATE = System.TriggerOperation.AFTER_UPDATE;
	private static final TriggerOperation AFTER_DELETE = System.TriggerOperation.AFTER_DELETE;
	private static final TriggerOperation AFTER_UNDELETE = System.TriggerOperation.AFTER_UNDELETE;

	@IsTest
	static void testCallingTriggerOperations()
	{
		SObjectEventListener eventListener = new SObjectEventListener();
		System.assert(eventListener.calledTriggerOperations.isEmpty(), 'Improper test data for unit-test');

		eventListener.handle(new SObjectEvent(BEFORE_INSERT));
		System.assert(eventListener.calledTriggerOperations.contains(BEFORE_INSERT));

		eventListener.handle(new SObjectEvent(AFTER_INSERT));
		System.assert(eventListener.calledTriggerOperations.contains(AFTER_INSERT));

		eventListener.handle(new SObjectEvent(BEFORE_UPDATE));
		System.assert(eventListener.calledTriggerOperations.contains(BEFORE_UPDATE));

		eventListener.handle(new SObjectEvent(AFTER_UPDATE));
		System.assert(eventListener.calledTriggerOperations.contains(AFTER_UPDATE));

		eventListener.handle(new SObjectEvent(BEFORE_DELETE));
		System.assert(eventListener.calledTriggerOperations.contains(BEFORE_DELETE));

		eventListener.handle(new SObjectEvent(AFTER_DELETE));
		System.assert(eventListener.calledTriggerOperations.contains(AFTER_DELETE));
	}

	public class SObjectEvent
			extends fflib_SObjectEvent
	{
		public SObjectEvent(System.TriggerOperation operationType)
		{
			this.records = new List<Account>{ new Account(Name = 'Test')};
			this.operationType = operationType;
		}
	}

	public class SObjectEventListener
			extends fflib_SObjectEventListener
	{
		public Set<System.TriggerOperation> calledTriggerOperations =
				new Set<System.TriggerOperation>();

		public override void onBeforeInsert()
		{
			calledTriggerOperations.add(BEFORE_INSERT);
		}

		public override void onBeforeUpdate()
		{
			calledTriggerOperations.add(BEFORE_UPDATE);
		}

		public override void onBeforeDelete()
		{
			calledTriggerOperations.add(BEFORE_DELETE);
		}

		public override void onAfterInsert()
		{
			calledTriggerOperations.add(AFTER_INSERT);
		}

		public override void onAfterUpdate()
		{
			calledTriggerOperations.add(AFTER_UPDATE);
		}

		public override void onAfterDelete()
		{
			calledTriggerOperations.add(AFTER_DELETE);
		}

		public override void onAfterUndelete()
		{
			calledTriggerOperations.add(AFTER_UNDELETE);
		}
	}
}