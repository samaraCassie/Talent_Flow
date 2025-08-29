package talent_flow.entities;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

public class UserCompetencyId implements Serializable {
    private UUID userId;
    private UUID competencyId;

    public UserCompetencyId() {}

    public UserCompetencyId(UUID userId, UUID competencyId) {
        this.userId = userId;
        this.competencyId = competencyId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof UserCompetencyId)) return false;
        UserCompetencyId that = (UserCompetencyId) o;
        return Objects.equals(userId, that.userId) &&
                Objects.equals(competencyId, that.competencyId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, competencyId);
    }
}
