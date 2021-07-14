--delete an Entity
use LogRhythmEMDB
go

--------------------------------------------------------------------------------------------
--------------------- PLEASE NEVER NEVER DELETE ENTITY ID 1 --------------------------------
--------------------------------------------------------------------------------------------
declare @EntityId int
declare @EntityName varchar(50)


Set @EntityName = '%ToBeDeleted%'

DECLARE EntityCursor CURSOR
FOR Select entityid
    from dbo.Entity
    where FullName like @EntityName

Begin tran

Open EntityCursor; 
While (1 = 1)
Begin
	Fetch NEXT from EntityCursor
	into @EntityId;

	if (@@FETCH_STATUS <> 0)
	    break;

    if (@EntityId = 1 or @EntityId = -100)
	begin
	    raiserror('Deleting EntityID: %d Not Allowed',0,1,@EntityId) with nowait;
		break;
    end;

	Print 'Deleting records for EntityID: ' + convert(varchar(9),@EntityId);

	Delete dbo.UserProfileLSPerm where MsgSourceID in (select MsgSourceID from dbo.MsgSource where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Delete dbo.AIEEngineToMsgSource where MsgSourceID in (select MsgSourceID from dbo.MsgSource where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Delete dbo.HostIdentifierToMsgSource where MsgSourceID in (select MsgSourceID from dbo.MsgSource where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Delete dbo.MsgSource where HostID in (select HostId from dbo.Host where EntityID = @EntityId)

	--Check if any msg source is left
	--select MsgSourceID,SystemMonitorID from dbo.MsgSource where HostID in (select HostId from dbo.Host where EntityID = @EntityId)

	--Delete dbo.MsgSource WHERE SystemMonitorID = 

	delete dbo.FIMPolicyToSystemMonitor where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))
	
	delete dbo.SMSNMPV3Credential where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Delete dbo.MediatorSession where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Delete dbo.SystemMonitorToMediator where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	delete dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId)

	Delete dbo.HostIdentifier WHERE HostID in (select HostId from dbo.Host where EntityID = @EntityId)
	
	Delete dbo.ObjectControl WHERE EntityId in (select EntityId from dbo.Entity where EntityID = @EntityId)

	delete dbo.WatchItem where NetworkID in (select NetWorkID from dbo.Network WHERE EntityID = @EntityId)

	Delete dbo.Network WHERE EntityId in (select EntityId from dbo.Entity where EntityID = @EntityId)
	
	Delete dbo.WatchItem WHERE HostID in (select HostId from dbo.Host where EntityID = @EntityId)
	
	--once the above done for all entities, then delete each from the host
	delete dbo.Host where EntityID = @EntityId

	--Check if this is parent entity or child
	delete dbo.Entity where EntityID = @EntityId
End;

Close EntityCursor;
DEALLOCATE EntityCursor;

commit tran