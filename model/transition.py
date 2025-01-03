from __future__ import annotations
import model.state as state


class Transition:
    '''
    A transition connects two states within an automaton.
    Transitions are guarded with conditionals, or world state that
    must hold true for a transition to "fire."

    TODO: Transitions may also require a trigger to fire, which is
    not yet implemented.
    '''

    source_id: int
    target_id: int
    source: state.State | None
    target: state.State | None
    event: state.LabeledFormula
    condition: state.LabeledFormula

    def __init__(self,
                 source_id: int,
                 target_id: int,
                 event=None,
                 condition=True) -> None:
        self.source_id = source_id
        self.target_id = target_id

        # triggering event
        self.event = event

        # conditionals
        self.condition = condition

    def __str__(self):
        condition = str(self.condition)
        if condition == "None" or condition == "True":
            condition = ""
        event = ""
        if self.event is not None:
            event = "[{}] ".format(self.event.name)
        return "t: {}{} -{}> {}".format(event,
                                        self.source_id,
                                        condition,
                                        self.target_id)
